#!/usr/bin/env ruby
# frozen_string_literal: true

# Filter a Premium Request Usage Report CSV to rows whose username belongs
# to a given GitHub Organization team.
#
# Usage:
#   ruby filter_by_team.rb <org> <team-slug> <input.csv> [output.csv]
#
# Requires the `gh` CLI authenticated with read access to the organization.

require "csv"
require "open3"
require "pathname"

def fetch_team_members(org, team)
  stdout, stderr, status = Open3.capture3(
    "gh", "api", "orgs/#{org}/teams/#{team}/members",
    "--paginate", "-q", ".[].login"
  )
  unless status.success?
    warn "gh api failed: #{stderr}"
    exit 1
  end
  stdout.each_line.map(&:strip).reject(&:empty?).to_set
end

def default_output_path(src, team)
  stem = src.basename(src.extname).to_s
  suffix = stem.split("_").find { |t| t.match?(/\A\d{6}\z|\A\d{8}\z/) }
  filename = suffix ? "#{team}_#{suffix}.csv" : "#{team}.csv"
  src.dirname.join(filename)
end

def filter_csv(src, dst, members)
  members_lower = members.map(&:downcase).to_set
  matched = Set.new
  rows = 0

  CSV.open(dst, "w", force_quotes: true) do |writer|
    CSV.foreach(src, headers: true, return_headers: true, encoding: "bom|utf-8") do |row|
      if row.header_row?
        writer << row.headers
        next
      end
      username = row["username"].to_s
      next unless members_lower.include?(username.downcase)
      writer << row
      matched << username
      rows += 1
    end
  end

  [rows, matched]
end

require "set"

if ARGV.length < 3 || ARGV.length > 4
  warn "Usage: ruby filter_by_team.rb <org> <team-slug> <input.csv> [output.csv]"
  exit 2
end

org, team, src_str, dst_str = ARGV
src = Pathname.new(src_str)
unless src.file?
  warn "Input CSV not found: #{src}"
  exit 1
end
dst = dst_str ? Pathname.new(dst_str) : default_output_path(src, team)

members = fetch_team_members(org, team)
rows, matched = filter_csv(src, dst, members)
missing = (members - matched).sort_by(&:downcase)

puts "Team #{org}/#{team}: #{members.size} members"
puts "Wrote #{rows} rows for #{matched.size} active users -> #{dst}"
unless missing.empty?
  puts "No usage in CSV (#{missing.size}): #{missing.join(', ')}"
end
