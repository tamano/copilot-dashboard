#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate an HTML dashboard from a GitHub Copilot premium request usage CSV.
# Usage: ruby generate_dashboard.rb <csv_path> [output_path]

require "csv"
require "json"
require "time"

TEMPLATE_PATH = File.join(__dir__, "template.html")

def main
  csv_path = ARGV[0]

  unless csv_path
    warn "Usage: ruby generate_dashboard.rb <csv_path> [output_path]"
    exit 1
  end

  rows = read_csv(csv_path)
  output_path = ARGV[1] || default_output_path(rows)
  data = build_dashboard_data(rows)
  generate_html(data, output_path)

  puts "Dashboard generated: #{output_path}"
end

def default_output_path(rows)
  dates = rows.map { |r| r[:date] }.compact.sort
  if dates.empty?
    return File.join(Dir.pwd, "dashboard.html")
  end
  start_date = dates.first.delete("-")
  end_date = dates.last.delete("-")
  File.join(Dir.pwd, "dashboard_#{start_date}_#{end_date}.html")
end

def read_csv(path)
  content = File.read(path, encoding: "bom|utf-8")
  CSV.parse(content, headers: true, liberal_parsing: true).map do |row|
    {
      date: row["date"]&.strip&.delete('"'),
      username: row["username"]&.strip&.delete('"'),
      product: row["product"]&.strip&.delete('"'),
      model: row["model"]&.strip&.delete('"'),
      quantity: row["quantity"]&.strip&.delete('"').to_f,
      gross_amount: row["gross_amount"]&.strip&.delete('"').to_f,
      net_amount: row["net_amount"]&.strip&.delete('"').to_f,
      total_monthly_quota: row["total_monthly_quota"]&.strip&.delete('"').to_f,
      organization: row["organization"]&.strip&.delete('"'),
    }
  end
end

def build_dashboard_data(rows)
  return empty_data if rows.empty?

  total_requests = rows.sum { |r| r[:quantity] }
  total_cost = rows.sum { |r| r[:net_amount] }
  users = rows.map { |r| r[:username] }.uniq
  dates = rows.map { |r| r[:date] }.uniq.sort
  quota = rows.first[:total_monthly_quota]
  org = rows.first[:organization] || ""

  user_stats = build_user_stats(rows, quota)
  avg_quota_pct = user_stats.empty? ? 0.0 : user_stats.sum { |u| u[:quota_pct] } / user_stats.size
  exceeded_users = user_stats.count { |u| u[:quota_pct] >= 100 }

  {
    summary: {
      total_requests: total_requests.round(1),
      total_cost: total_cost.round(2),
      active_users: users.size,
      date_range: "#{dates.first} ~ #{dates.last}",
      total_monthly_quota: quota.to_i,
      organization: org,
      avg_quota_pct: avg_quota_pct.round(1),
      exceeded_users: exceeded_users,
      generated_at: Time.now.strftime("%Y-%m-%d %H:%M"),
    },
    daily_trend: build_daily_trend(rows, dates, users, quota),
    user_stats: user_stats,
    model_stats: build_model_stats(rows),
  }
end

def build_user_stats(rows, quota)
  by_user = rows.group_by { |r| r[:username] }
  stats = by_user.map do |username, user_rows|
    total_req = user_rows.sum { |r| r[:quantity] }
    total_cost = user_rows.sum { |r| r[:net_amount] }
    quota_pct = quota > 0 ? (total_req / quota * 100) : 0.0
    models = user_rows.group_by { |r| r[:model] }.transform_values { |mrs| mrs.sum { |r| r[:quantity] }.round(1) }
    {
      username: username,
      total_requests: total_req.round(1),
      total_cost: total_cost.round(4),
      quota_pct: quota_pct.round(1),
      models: models,
    }
  end
  stats.sort_by { |u| -u[:total_requests] }
end

def build_daily_trend(rows, dates, users, quota)
  by_date = rows.group_by { |r| r[:date] }

  # Track cumulative usage per user across dates to detect quota exceedance
  cumulative = Hash.new(0.0)
  daily_requests = []
  quota_exceeded_count = []

  dates.each do |date|
    day_rows = by_date[date] || []
    daily_total = day_rows.sum { |r| r[:quantity] }
    daily_requests << daily_total.round(1)

    # Accumulate per-user usage
    day_rows.each { |r| cumulative[r[:username]] += r[:quantity] }

    # Count users who have exceeded quota by this date
    exceeded = cumulative.count { |_user, total| quota > 0 && total >= quota }
    quota_exceeded_count << exceeded
  end

  {
    dates: dates,
    daily_requests: daily_requests,
    quota_exceeded_count: quota_exceeded_count,
  }
end

def build_model_stats(rows)
  by_model = rows.group_by { |r| r[:model] }
  stats = by_model.map do |model, model_rows|
    {
      model: model,
      total_requests: model_rows.sum { |r| r[:quantity] }.round(1),
      total_cost: model_rows.sum { |r| r[:net_amount] }.round(4),
    }
  end
  stats.sort_by { |m| -m[:total_requests] }
end

def empty_data
  {
    summary: { total_requests: 0, total_cost: 0, active_users: 0, date_range: "-", total_monthly_quota: 0, organization: "-", avg_quota_pct: 0, exceeded_users: 0, generated_at: Time.now.strftime("%Y-%m-%d %H:%M") },
    daily_trend: { dates: [], daily_requests: [], quota_exceeded_count: [] },
    user_stats: [],
    model_stats: [],
  }
end

def generate_html(data, output_path)
  template = File.read(TEMPLATE_PATH)
  json_str = JSON.generate(data)
  html = template.sub("/*{{DASHBOARD_DATA}}*/null", json_str)
  File.write(output_path, html)
end

main
