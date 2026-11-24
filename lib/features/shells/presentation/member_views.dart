import 'package:flutter/material.dart';

import '../../booking/presentation/member_bookings_view.dart';
import '../../booking/presentation/member_schedule_view.dart';
import '../../facility_access/presentation/member_pass_view.dart';

class MemberHomeView extends StatelessWidget {
  const MemberHomeView({super.key});

  @override
  Widget build(BuildContext context) => const MemberPassView();
}

class MemberScheduleView extends StatelessWidget {
  const MemberScheduleView({super.key});

  @override
  Widget build(BuildContext context) => const MemberScheduleBrowseView();
}

class MemberBookingsView extends StatelessWidget {
  const MemberBookingsView({super.key});

  @override
  Widget build(BuildContext context) => const MemberBookingsListView();
}
