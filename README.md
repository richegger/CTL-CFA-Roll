# CTL-CFA-Roll
SQL pull and R transformation to see whether an install or rollover charge is correct.

The purpose of this is to show an initial SQL data pull, then transform the data in R to something that shows what type of charge
is correct for a specific order: an installation or a rollover.

SQL data pull:
We've created 4 CTEs in order for our query to work.  The first pulls the channel termination installation charges for a particular
month.  The second pulls the rollover charges for that same month.  The third CTE pulls circuit, CFA, and end user address information
for the same month as the installion and rollover charges.  The last CTE pull the same information as the third, only for the month prior.
Our query then links everything together, pulling in the circuits that had an installation charge, showing whether or not the same 
circuit had a rollover charge, and then displaying the CFA and end user address information for our two month time period.  The great
this about this query is that it can be run for multiple months very quickly just by changing the date variables at the beginning of the
file.  

R transformation:
After the data is loaded, the stringr package is used to extract the CLLI information from the CFAs and slice them down to base 8
characters.  A logical comparison is made to see if each location from the new CFA exists in the old CFA, and vice versa.  We then check
the end user address's first 10 characters, with an assumption made that if the first 10 characters are the same, the entire address is
the same.  Depending on the outcome of these steps the file will tell you whether an installation charge or a rollover charge is
appropriate.
