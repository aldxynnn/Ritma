import 'package:flutter/material.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../booking/presentation/member_bookings_view.dart';
import '../../booking/presentation/member_schedule_view.dart';
import '../../facility_access/presentation/member_pass_view.dart';
import '../../personal_training/presentation/pt_sessions_view.dart';

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

class MemberBookingsView extends StatefulWidget {
  const MemberBookingsView({super.key});

  @override
  State<MemberBookingsView> createState() => _MemberBookingsViewState();
}

class _MemberBookingsViewState extends State<MemberBookingsView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            RitmaSpacing.md,
            RitmaSpacing.md,
            RitmaSpacing.md,
            0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(
                  value: 0,
                  icon: Icon(Icons.bookmark_outline),
                  label: Text('Classes'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: Icon(Icons.fitness_center_outlined),
                  label: Text('Personal Training'),
                ),
              ],
              selected: <int>{_tab},
              onSelectionChanged: (values) =>
                  setState(() => _tab = values.first),
            ),
          ),
        ),
        Expanded(
          child: _tab == 0
              ? const MemberBookingsListView()
              : const PtSessionsView(),
        ),
      ],
    );
  }
}
