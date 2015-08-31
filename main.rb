require 'date'
require_relative 'NICalc.rb'
require_relative 'Employee.rb'
$MAGIC_DATE = '1970-01-01'

#------------------------------------------------------------------
bob = Employee.new
#TODO - holding DOB and DOBverified are not date effective.
#       How should these be passed?
#TODO - contracted out and mariner flags come from job details
#       so will be a separate DateEffective?
#       As will apprentice flags next year
#       Maybe just a merge function in DateEffective to combine them
bob.dateOfBirth = '1980-01-01'
bob.employmentStartDate = '2010-01-01'
bob.legislation.add(:DateOfBirth, bob.dateOfBirth)
bob.legislation.add(:NiSpecialExemption, false)
bob.legislation.add(:NiMariner, false)
bob.legislation.add(:NiOverStatePensionAge, true)
bob.legislation.add(:NiContractedOut, true)
bob.legislation.add(:NiMarriedReduced, false)
bob.legislation.add(:NiUnder21, false)
bob.legislation.add(:NiDeferred, false)
bob.legislation.add(:DateOfBirthVerified, true)

niPay = UkNationalInsurance.new(	value: 2000.00,
									payDate: '2015-05-31',
									payFrequency: :month,
									flags: bob.legislation
									)

puts niPay.Calc
# puts niPay.inspect
# puts UkNationalInsurance::SUPPORTED_YEARS
# puts bob.legislation.inspect
# puts bob.legislation.valueAtDate(:NiMariner, '2015-08-26')

#I THINK THE DATA SHOULD LOOK LIKE THIS
# bob.person.add(:DateOfBirth, '1980-01-01')
# bob.person.add(:DateOfBirthVerified, true)
# bob.person.add(:Forenames, %w[Bob, Archibald, Frederick])
# bob.person.add(:Surname, %w(O'Toole)
# bob.legislation.ukni.add(:NiSpecialExemption, false)
# bob.legislation.ukni.add(:NiMariner, false)
# bob.legislation.ukni.add(:NiMarriedReduced, false)
# bob.legislation.ukni.add(:NiDeferred, false)
# bob.legislation.age.add(:StatePensionAge, nil)
# bob.legislation.age.add(:Age21, nil)
# bob.job.0.add(:Id, 'Job1')
# bob.job.0.add(:StartDate, '2015-01-01')
# bob.job.0.legislation.ukni.add(:NiContractedOut, true)
