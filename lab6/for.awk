BEGIN {
	printf("\nTotal hours worked this month:\n")	
}
{
	count = split($5, hours, ",")
	total = 0
#	could also be for(x=1; x<= count; x++)
	for(x in hours)
		total = total + hours[x]
	printf("%s %s worked %d hours this month.\n", $1, $2, total)
}

