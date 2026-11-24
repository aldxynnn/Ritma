import 'package:freezed_annotation/freezed_annotation.dart';

part 'operational_metrics_model.freezed.dart';
part 'operational_metrics_model.g.dart';

@freezed
abstract class OperationalMetricsModel with _$OperationalMetricsModel {
  const factory OperationalMetricsModel({
    @JsonKey(name: 'active_members') @Default(0) int activeMembers,
    @JsonKey(name: 'today_visits') @Default(0) int todayVisits,
    @JsonKey(name: 'window_revenue_minor') @Default(0) int windowRevenueMinor,
    @JsonKey(name: 'class_capacity_total') @Default(0) int classCapacityTotal,
    @JsonKey(name: 'class_confirmed_total') @Default(0) int classConfirmedTotal,
    @JsonKey(name: 'class_occupancy_pct')
    @Default(0.0)
    double classOccupancyPct,
    @JsonKey(name: 'expiring_entitlements_7d')
    @Default(0)
    int expiringEntitlements7d,
  }) = _OperationalMetricsModel;

  factory OperationalMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$OperationalMetricsModelFromJson(json);
}
