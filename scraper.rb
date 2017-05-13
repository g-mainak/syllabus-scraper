require 'mechanize'

Dir.mkdir 'files' unless File.exists? 'files'
agent = Mechanize.new
agent.pluggable_parser.default = Mechanize::Download
broken = ""

page = agent.get('http://classesv2.yale.edu/')
p = agent.page.link_with(text: "Syllabus Browser").click

p =  p.iframe().click
form = p.links[1].click.form
form.username = ARGV[0]
form.password = ARGV[1]
q = agent.submit(form, form.buttons.first)

subjects = p.form.fields[2].options
choose_subject = p.form.fields[2]
subjects.each do |subject|
	choose_subject.value = subject.value
	new_page = agent.submit(p.form)
	puts new_page.links[1]

	new_page.links.each do |link|
		begin
			q = link.click
			class_name = q.search('.textPanelHeader')
			if class_name.first
				class_name = class_name.first.text
			else
				class_name = class_name.text
			end
			class_name.gsub!('/', '')
			puts class_name
			if q.links.count == 2
				file_name = 'files/[' + class_name + ']' + q.links[1].click.filename
				q.links[1].click.save(file_name)
			else
				File.write("files/" + class_name + ".html", q.search('tbody').to_html)
			end
		rescue
			broken << link.text + "\n"
		end
	end
end

puts broken