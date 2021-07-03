import 'package:intl/intl.dart';
import 'package:theproject/enum/userState.dart';

class Utils {
  dateGiver() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate);
    return formattedDate;
  }

  messageTimer(timing) {
    final date = DateTime.fromMillisecondsSinceEpoch(timing);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);
    String time = DateFormat.jm().format(date);
    return time;
  }

  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.Offline:
        return 0;

      case UserState.Online:
        return 1;

      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.Offline;

      case 1:
        return UserState.Online;

      default:
        return UserState.Waiting;
    }
  }
}
