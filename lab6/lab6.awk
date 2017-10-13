{
  if (40-$5 < 0){
    compensation=(40 * $4) + (($5-40) * ($4*1.5))
    printf "%s %s %s %d %s %.2f\n", $1, $2, "worked", $5, "hours, for a total pay of", compensation
}
  else{
    compensation=(40 * $4)
    printf "%s %s %s %d %s %.2f\n", $1, $2, "worked", $5, "hours, for a total pay of", compensation
}
}
