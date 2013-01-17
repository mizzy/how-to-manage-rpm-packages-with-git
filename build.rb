#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'uri'
require 'facter'
require 'fileutils'

# rpmbuild directory
rpmbuild_top_dir     = `rpm --eval='%_topdir'`.strip
rpmbuild_sources_dir = File.join(rpmbuild_top_dir, 'SOURCES')

# The directory for built packages.
# This directory is synchronized with other servers
os         = Facter.value(:operatingsystem)
release    = Facter.value(:operatingsystemrelease).split('.')[0]
arch       = Facter.value(:architecture)
base_dir   = '/var/tmp/packages'
srpms_dir  = File.join(base_dir, 'SRPMS')
rpms_dir   = File.join(base_dir, os, release, arch, 'RPMS')

FileUtils.mkdir_p(srpms_dir) unless Dir.exist?(srpms_dir)
FileUtils.mkdir_p(rpms_dir)  unless Dir.exist?(rpms_dir)

# Traverse each package directory
Dir.entries('.').each do |e|
  next if e.match(/^\./)
  next if File.file?(e)
  # In a package directory
  Dir.chdir(e) do
    spec = ''
    Dir.glob('*').each do |file|
      # If find src.rpm file, extract it
      if file.match(/\.src\.rpm$/)
        `rpm -Uvh #{file}`
      # if fine spec file, get sources in it
      elsif file.match(/\.spec$/)
        spec = file
        open(spec) do |f|
          while l = f.gets
            l.match(/^(Source\d?):\s+(.+)$/) do |m|
              `spectool --sourcedir -g #{spec}` if m[2].match(/^https?/)
            end
          end
        end
      # other files are copied to rpmbuild sources directory
      elsif
        FileUtils.cp(file, rpmbuild_sources_dir)
      end
    end

    # make src.rpm file
    srpm = `rpmbuild -bs #{spec}`.match(/^Wrote:\s+(.+)$/)[1]

    # install dependency files with yum-builddep

    puts `sudo yum-builddep -y #{srpm}`

    # copy src.rpm file to the directory for sync
    FileUtils.cp(srpm, srpms_dir)
    log = `rpmbuild --rebuild #{srpm}`
    log.split("\n").each do |line|
      line.match(/^Wrote:\s+(.+)$/) do |m|
        # copy rpm files to the directory for sync
        FileUtils.cp(m[1], rpms_dir)
      end
    end
  end
end

# sync build packages with other servers
# (in this example, not with other servers but with other directory)
puts `rsync -a #{yum_dir}/ /home/mizzy/yum`
repo_dir = File.join('/home/mizzy/yum', os, release, arch)

# execute createrepo command for serving to yum command
`createrepo #{repo_dir}`
