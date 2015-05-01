#! /usr/bin/env ruby
# encoding: utf-8
#
#  THIS IS A GREAT EXAMPLE OF VERY POOR CODING PRACTICES.
#  IT IS HERE FOR HISTORICAL REFERENCE PURPOSES.
#
#  bpc - Benefit Package Calculator 
#  Joseph Martin 2013.08.10
#
######################################

require 'optparse'

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner =	"Benefits Package Calculator" 
  opt.separator	"\nUsage: bpc [OPTIONS]"
  opt.separator	"Options"

  opt.on("-s","--salary ANUAL_SALARY","Proposed base salary") do |salary|
    options[:salary] = salary.to_f
  end

  options[:tax] = 37.6
  opt.on("-t","--tax-rate TAX_RATE","Total payroll tax percentage") do |tax|
    options[:tax] = tax.to_f
  end

  options[:wks_pto] = 2.0
  opt.on("-w","--weeks-pto NUMBER_OF_WEEKS","Weeks of paid time off") do |wks_pto|
    options[:wks_pto] = wks_pto.to_f
  end

	# 15% - 30%
  options[:bonus_perc] = 22.0
  opt.on("-b","--bonus PERCENT","Bonus percent") do |bonus_perc|
    options[:bonus_perc] = bonus_perc.to_f
  end

	# Up to $17500 anually
	options[:"fourohone"] = 17500.00
  opt.on("-f","--fourohone ANUAL_INVESTMENT","Anual 401K investment") do |fourohone|
    options[:"fourohone"] = fourohone.to_f
  end

	options[:"limit"] = 17500.00
  opt.on("-l","--limit CONTRIBUTION_LIMIT","Employer 401K contribution limit") do |limit|
    options[:"limit"] = limit.to_f
  end

	options[:"contrib"] = 4.0
  opt.on("-c","--contrib CONTRIBUTION_PERC","Employer 401K contribution percent") do |contrib|
    options[:"contrib"] = contrib.to_f
  end

	options[:premium] = 400.0
  opt.on("-p","--premium MONTHLY_PREMIUM","Monthly insurance premium") do |premium|
    options[:premium] = premium.to_f
  end

	options[:employer] = 0.0
  opt.on("-e","--employer PREMIUM_PERC","Percentage of insurance premium paid by employer") do |employer|
    options[:employer] = employer.to_f
  end

	options[:deductible] = 0.0
  opt.on("-d","--deductible CONTRIBUTION","Anual insurance deductible contribution") do |deductible|
    options[:deductible] = deductible.to_f
  end

	options[:rate] = 15.0
  opt.on("-r","--rate DISCOUNT_RATE","Employee Stock Program discount rate") do |rate|
    options[:rate] = rate.to_f
  end

	# Up to 15% gross can be invested at 15% discount
	options[:invest] = 15.0
  opt.on("-i","--invest STOCK_PERC","Percentage of gross to invest in ESP") do |invest|
    options[:invest] = invest.to_f
  end

	options[:growth] = 0.0
  opt.on("-g","--growth STOCK_PERC","Percentage of growth in stock value") do |growth|
    options[:growth] = growth.to_f
  end

	options[:other] = 0.0
  opt.on("-o","--other ANUAL_OTHER","Anual value of miscellaneous soft benefit") do |other|
    options[:other] = other.to_f
  end

  opt.on("-h","--help","Display this screen") do
		puts opt_parser
		exit
  end

  opt.separator  ""
end

begin   
	opt_parser.parse!
	mandatory = [:salary]
	missing = mandatory.select{ |param| options[param].nil? }
	if not missing.empty?
		puts opt_parser
		puts "Required options: --#{missing.join(', ')}"
		exit
	end
	rescue OptionParser::InvalidOption, OptionParser::MissingArgument
		puts opt_parser
		puts $!.to_s
		exit
end

	salary=options[:salary]
	hourly=salary/52/40
	after_tax=(100.0-options[:tax])/100.0
	pto=options[:wks_pto]
	pto_value=hourly*40*pto
	bonus=salary*(options[:bonus_perc]/100)
	fourohone=options[:fourohone]
	if fourohone > 17500
		fourohone=17500
	end
	contrib=fourohone*(options[:"contrib"]/100)
	if contrib > options[:limit]
		contrib=options[:limit]
	end

	bills={
		'dailyCash' => '40.00',
		'childSupport1' => '561.00',
		'childSupport2' => '505.00',
		'rent1' => '725.00',
		'rent2' => '725.00',
		'phone1' => '79.00',
		'phone2' => '79.00',
		'storage' => '82.00',
		'travel' => '95.00',
		'utility1' => '0.00',
		'utility2' => '0.00',
		'utility3' => '0.00',
		'utility4' => '0.00',
		'utility5' => '0.00',
		'misc' => '0.00'
	}

	cash=bills['dailyCash'].to_i*365/12
	support=(bills['childSupport1'].to_i+bills['childSupport2'].to_i)*26/12
	rent=bills['rent1'].to_i+bills['rent2'].to_i
	phones=bills['phone1'].to_i+bills['phone2'].to_i
	storage=bills['storage'].to_i
	utilities=bills['utility1'].to_i+bills['utility2'].to_i+bills['utility3'].to_i+bills['utility4'].to_i+bills['utility5'].to_i
	other=bills['misc'].to_i
	medical=((options[:premium]*(options[:employer]/100))*12)+options[:deductible]
	investment=salary*(options[:invest]/100)
	stock=((investment/((100-options[:rate])/100))*(1+(options[:growth].to_i/100.0)))-investment
	monthly=((salary*after_tax/12.0)-(options[:premium]*(1-(options[:employer]/100)))-((investment+fourohone)/12))
	other=options[:other]
	total=salary+pto_value+bonus+contrib+medical+stock+other

	expenses=cash+support+rent+phones+storage+utilities+other+options[:premium]
	min=expenses-(investment/12)
	max=176000.00
	
	puts ""
	puts "Salary offer:			" + '$' + salary.round(2).to_s
	puts "Hourly equivalent:		" + '$' + hourly.round(2).to_s
	puts "Total tax rate:			" + options[:tax].to_s + '%'
	puts "Monthly budget*:		" + '$' + monthly.round(2).to_s
	puts "Monthly expenses:		" + '$' + expenses.round(2).to_s
	puts "PTO per year:			" + pto.round(0).to_s + " weeks"
	puts 'PTO value:			' + '$' + pto_value.round(2).to_s
	puts "Anual bonus percentage:		" + options[:bonus_perc].to_s + '%'
	puts 'Anual bonus:			' + '$' + bonus.round(2).to_s
	puts "401K investment:		" + '$' + fourohone.round(2).to_s
	puts "Employer 401K contribution:	" + options[:"contrib"].to_s + '%'
	puts "401K contribution value:	" + '$' + contrib.round(2).to_s
	puts "Monthly insurance premium:	" + '$' + options[:premium].to_s
	puts "Employer premium contribution:	" + options[:employer].to_s + '%'
	puts "Deductible contribution:	" + '$' + options[:deductible].to_s
	puts "Medical contribution:		" + '$' + (medical).round(2).to_s
	puts "Employee stock discount:	" + options[:rate].to_s + '%'
	puts "Employee stock invested:	" + options[:invest].to_s + '%'
	puts "Monthly stock investment:	" + '$' + (investment/12).round(2).to_s
	puts "Anual stock gain at " + options[:growth].to_s + '%:	$' + stock.round(2).to_s
	puts "Other soft benefit:		" + '$' + other.round(2).to_s
	puts ""

	puts 'Total package:			' + '$' + total.round(2).to_s
	puts ""
	puts "* Take-home after taxes and benefit contributions."

exit(0)

