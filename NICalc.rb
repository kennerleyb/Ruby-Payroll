# require 'date'

class UkLegislation
	CONTAINS = [:UkNationalInsurance, :UkPaye]
end

class NiPay
	#TODO - could just make the UKNationalInsurance object the structure?
	attr_accessor :value, :payDate, :payFrequency, :payPeriods, :flags
	def initialize(value:, payDate:, payFrequency:, payPeriods:1, flags:)
		@payValue = value
		@payDate = payDate
		@payFrequency = payFrequency
		@payPeriods = payPeriods
		@flags = flags
	end
end

#------------------------------------------------------------------
class UkNationalInsurance
	SUPPORTED_YEARS = [2015]
	
	def self.Calc(niPay:)
		#need to calculate which tax year the payment date is in
		#subtract 5 days and 3 months
		taxYear = ((Date.parse(niPay.payDate) - 5) << 3).year
		raise "Invalid Tax Year #{taxYear}" unless SUPPORTED_YEARS.include? taxYear
		#then call the correct function to determine the NI category
		niPay.cat = self.send("NiCategory#{taxYear}", niPay.flags, niPay.payDate)
		#TODO - calculate under 21 rather than use a flag
		#TODO - calculate overstatepensionage, using dob and dobverified
		#TODO - handle multiple payments being passed, for now just reject
		#TODO - what about directors NI?
		niPay.bandings = self.send("NiBandings#{taxYear}", niPay.flags, niPay.payDate)
		niPay.deductions = self.send("NiDeductions#{taxYear}", niPay.flags, niPay.payDate)
	end

	def self.NiCategory2015 (flags, effDate)
		currFlags = flags.valuesAtDate(effDate)
		if currFlags[:NiSpecialExemption] then 'X'
		elsif currFlags[:NiMariner]
			#MARINERS
			if currFlags[:NioverStatePensionAge] then 'W'
			elsif currFlags[:NicontractedOut]
				#MARINERS, CONTRACTED OUT - N, O, V
				if currFlags[:NiMarriedReduced] then 'O'
				elsif currFlags[:NiUnder21] then 'V' else 'N'
				#there is no deferred contracted out rate for mariners
				end
			else
				#MARINERS, NOT CONTRACTED OUT - P, Q, R, T, Y
				if currFlags[:NiMarriedReduced] then 'T'
				elsif currFlags[:NiUnder21]
					if currFlags[:NiDeferred] then 'P' else 'Y' end
				elsif currFlags[:NiDeferred] then 'Q' else 'R' 
				end
			end
		else #NON-MARINERS
			if currFlags[:NiOverStatePensionAge] then 'C'
			elsif currFlags[:NiContractedOut]
				#NON-MARINERS, CONTRACTED OUT - D, E, I, K, L
				if currFlags[:NiMarriedReduced] then 'E'
				elsif currFlags[:NiUnder21]
					if currFlags[:NiDeferred] then 'K' else 'I' end
				elsif currFlags[:NiDeferred] then 'L' else 'D'
				end
			else
				#NON-MARINERS, NOT CONTRACTED OUT - A, B, J, M, Z
				if currFlags[:NiMarriedReduced] then 'B'
				elsif currFlags[:NiUnder21]
					if currFlags[:NiDeferred] then 'Z' else 'M' end
				elsif currFlags[:NiDeferred] then 'J' else 'A'
				end
			end
		end
	end



	def NICalc()
		#class to calculate UK National Insurance contributions
		#inputs needed - [payment date, pay frequency (defined by HMRC calc), NI category, NIable pay]. Could be multiple sets because of multiple employments, possible of different pay frequencies
		#output will be an array which will vary depending on tax year. [niCategory, eesNI, ersNI, earnings bands....] Could be multiple entries because of multiple NI categories (from 2016 is this true?)
	end

	def roundNI(value)
		#"Primary and secondary class 1 contributions shall be calculated to the nearest penny and any amount of a halfpenny or less shall be disregarded"
		#only look at the third decimal place where such calculation results in more than two decimal places
		#if it is 5 or less, round down
		#if it is 6 or more, round up
		pennies = (value*1000).abs.truncate			#force positive and remove unwanted decimal places. Is now an int.
		pennies += 10 if pennies.modulo(10) > 5		#if 3rd decimal place is >5, round up
		pennies *= -1 if value < 0					#change sign back again if necessary
		(pennies/10)/100.00							#adjust decimal places back again and convert to a float
	end

	def generateNIbandings(tax_year, pay, payFrequency, numPeriods, otherPay)
		# specByTaxYear = {}
		# specByTaxYear << {2015, %w(bLEL, LEL, LEL-PT, PT-ST, ST-UAP, UAP-UEL, aUEL, gross)}
		#iterate over the values and call the appropriate routine to generate it
		#store the return values in a hash
		#but.... this is all rubbish if there are multiple NI categories! how to handle that? Maybe a notional amount to be added on for cats already processed?

	end
end

#Monthly values
#LEL 486, PT 672, ST 676, UAP 3337, UEL 3532
#Bandings: <LEL, LEL-LEL, LEL-PT, PT-ST, ST-UAP, UAP-UEL, >UEL
#<LEL = 0-485.99
#LEL-LEL = 486
#LEL-PT = 0 - (672-486)
#PT-ST = 0 - (676-672)
#ST-UAP = 0 - (3337-676)
#UAP-UEL = 0 - (3532-3337)
#>UEL = 0 - INFINITY
#NIable gross = sum of the above

#RTI reporting needs gross earnings for NICs year to date. In order to balance the bandings back to this, we should return NI earnings <LEL and >UEL even though these are not reported to HMRC separately

