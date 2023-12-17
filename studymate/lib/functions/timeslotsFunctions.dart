import '../models/timeslot.dart';

List<String> convertListTimestampToPrint(List<dynamic> list) {
  List<String> timeToPrint = [];
  String? firstTimestamp;
  //Se c'è solo un elemento nel vettore
  if (list.length == 1) {
    timeToPrint.add(list[0]);
  }
  //Se ce ne sono almeno 2
  else {
    //Qui gestisco tutti gli elementi del vettore tranne l'ultimo
    for (var i = 0; i < list.length - 1; i++) {
      String x = list[i];
      String y = list[i + 1];
      int xInt = int.parse(x.substring(0, 2));
      int yInt = int.parse(y.substring(0, 2));

      //Se è il timestamp successivo
      if (xInt == (yInt - 1)) {
        //Se era vuoto (e quindi avevo aggiunto già un elemento nella lista) aggiungo l'attuale valore
        //altrimenti scorri il vettore
        firstTimestamp ??= x.substring(0, 5);
      }
      //Se il non è il timestamp successivo
      else {
        if (firstTimestamp == null) {
          timeToPrint.add(x);
        } else {
          timeToPrint.add(firstTimestamp + " - " + x.substring(8, 13));
          firstTimestamp = null;
        }
      }
    }
    //Uscito dalla lista rimarrà l'ultimo
    //Se era vuoto vuol dire che avevo già aggiunto in timeToPrint
    if (firstTimestamp == null) {
      timeToPrint.add(list[list.length - 1]);
    } else {
      String x = list[list.length - 1];
      timeToPrint.add(firstTimestamp + " - " + x.substring(8, 13));
    }
  }
  return timeToPrint;
}

List<String> getTimeslotOfDay(int day, TimeslotsWeek tsw) {
  List<String> timeslots = [];

  switch (day) {
    case 1:
      timeslots = tsw.monday.map((item) => item.toString()).toList();
      break;
    case 2:
      timeslots = tsw.tuesday.map((item) => item.toString()).toList();
      break;
    case 3:
      timeslots = tsw.wednesday.map((item) => item.toString()).toList();
      break;
    case 4:
      timeslots = tsw.thursday.map((item) => item.toString()).toList();
      break;
    case 5:
      timeslots = tsw.friday.map((item) => item.toString()).toList();
      break;
    case 6:
      timeslots = tsw.saturday.map((item) => item.toString()).toList();
      break;
    case 7:
      timeslots = tsw.sunday.map((item) => item.toString()).toList();
      break;
    default:
  }

  return timeslots;
}
