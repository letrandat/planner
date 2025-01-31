#!/usr/bin/env ruby

require_relative './shared'
FILE_NAME = "one-on-one_forms.pdf"

def one_on_one_page pdf, name, date
  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  pdf.define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)
  # grid.show_all

  pdf.grid([0, 0],[1, 1]).bounding_box do
    pdf.text name, heading_format(align: :left)
  end
  pdf.grid([1, 0],[1, 1]).bounding_box do
    pdf.text date.strftime(DATE_LONG), subheading_format(align: :left)
  end
  # grid([0, 2],[0, 3]).bounding_box do
  #   text "right heading", heading_format(align: :right)
  # end

  sections = {
    2 => "Personal/Notes: <color rgb='#{MEDIUM_COLOR}'>(Spouse, children, pets, hobbies, friends, history, etc.)</color>",
    5 => "Their Update: <color rgb='#{MEDIUM_COLOR}'>(Notes you take from their “10 minutes”)</color>",
    14 => "My Update: <color rgb='#{MEDIUM_COLOR}'>(Notes you make to prepare for your “10 minutes”)</color>",
    22 => "Future/Follow Up: <color rgb='#{MEDIUM_COLOR}'>(Where are they headed? Items that you will review at the next 1-on-1)</color>",
  }

  footer_start = 25
  footer_end = 29

  (2...footer_start).each do |row|
    pdf.grid([row, 0],[row, 3]).bounding_box do
      if sections[row]
        pdf.text sections[row], inline_format: true, valign: :bottom
      else
        pdf.stroke_line pdf.bounds.bottom_left, pdf.bounds.bottom_right
      end
    end
  end

  pdf.grid([footer_start, 0],[footer_start, 3]).bounding_box do
    pdf.text "Questions to Ask:", valign: :bottom, color: MEDIUM_COLOR
  end
  pdf.grid([footer_start + 1, 0],[footer_end, 1]).bounding_box do
    pdf.text "• Tell me about what you’ve been working on.\n" +
      "• Tell me about your week – what’s it been like?\n" +
      "• Tell me about your family/weekend/activities?\n" +
      "• Where are you on ( ) project?\n" +
      "• Are you on track to meet the deadline?\n" +
      "• What questions do you have about the project?\n" +
      "• What did ( ) say about this?", size: 10, color: MEDIUM_COLOR
  end
  pdf.grid([footer_start + 1, 2],[footer_end, 3]).bounding_box do
    pdf.text "• Is there anything I need to do, and if so by when?\n" +
      "• How are you going to approach this?\n" +
      "• What do you think you should do?\n" +
      "• So, you’re going to do “( )” by “( )”, right?\n" +
      "• What can you/we do differently next time?\n" +
      "• Any ideas/suggestions/improvements?", size: 10, color: MEDIUM_COLOR
  end

  # Back of the page
  begin_new_page pdf, :left
end

sunday, explanation = parse_start_of_week
puts explanation

monday = sunday.next_day(1)
next_sunday = sunday.next_day(7)
puts "Generating one-on-one forms for #{monday.strftime(DATE_FULL_START)}#{next_sunday.strftime(DATE_FULL_END)} into #{FILE_NAME}"

pdf = init_pdf

OOOS_BY_WDAY
  .each_with_index
  .reject { |names, _| names.nil? }
  .flat_map { |names, wday| names.map {|name| [name, sunday.next_day(wday)] } }
  .sort_by { |name, date| "#{name}#{date.iso8601}" } # Sort by name or date, as you like
  .each_with_index { |name_and_date, index|
    begin_new_page(pdf, :right) unless index.zero?
    one_on_one_page(pdf, *name_and_date)
  }

pdf.render_file FILE_NAME


