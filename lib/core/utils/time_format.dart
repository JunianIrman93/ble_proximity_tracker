import 'package:intl/intl.dart';

final _dateTime = DateFormat('d MMM yyyy, HH:mm');
final _time = DateFormat('HH:mm');
final _day = DateFormat('EEEE, d MMM yyyy');

String formatAgo(DateTime time, DateTime now) {
  final diff = now.difference(time);
  if (diff.inSeconds < 5) return 'just now';
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  return _dateTime.format(time);
}

String formatDateTime(DateTime time) => _dateTime.format(time);

String formatTime(DateTime time) => _time.format(time);

String formatDayHeader(DateTime day, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(day.year, day.month, day.day);
  final days = today.difference(date).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return _day.format(date);
}
