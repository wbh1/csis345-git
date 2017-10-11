BEGIN{
	print ("Calculating grade averages\n")
	FS=":"
}
{
	total = 0
	for(i=1; i < NF; i++){
		total += $(i)
	}
	student_avg[$(NF)] = total/(NF-1)
}
END {
  	i=0
	for ( name in student_avg ) {
		printf("%s has an average of %f\n", name, student_avg[name])
		class_avg_total += student_avg[name]
		i++
	}
			
	class_average = class_avg_total / NR
					
	for ( name in student_avg )
		if (student_avg[name] >= class_average)
			++above_average
		else
			++below_average
								
	print "Class Average: ", class_average
	print "At or Above Average: ", above_average
	print "Below Average: ", below_average
}
