String formatDateToFileName(){
  final dt = DateTime.now();
  final year = dt.year.toString();
  final month = to2Digits(dt.month.toString());
  final day = to2Digits(dt.day.toString());
  final hour = to2Digits(dt.hour.toString());
  final minute = to2Digits(dt.minute.toString());
  final sec = to2Digits(dt.second.toString());

  return "$year$month$day-$hour$minute$sec";
}

String to2Digits(String val){
  return val.length == 2 ? val : "0$val";
}