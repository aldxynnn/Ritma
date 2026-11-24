// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operational_metrics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OperationalMetricsModel _$OperationalMetricsModelFromJson(
  Map<String, dynamic> json,
) => _OperationalMetricsModel(
  activeMembers: (json['active_members'] as num?)?.toInt() ?? 0,
  todayVisits: (json['today_visits'] as num?)?.toInt() ?? 0,
  windowRevenueMinor: (json['window_revenue_minor'] as num?)?.toInt() ?? 0,
  classCapacityTotal: (json['class_capacity_total'] as num?)?.toInt() ?? 0,
  classConfirmedTotal: (json['class_confirmed_total'] as num?)?.toInt() ?? 0,
  classOccupancyPct: (json['class_occupancy_pct'] as num?)?.toDouble() ?? 0.0,
  expiringEntitlements7d:
      (json['expiring_entitlements_7d'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OperationalMetricsModelToJson(
  _OperationalMetricsModel instance,
) => <String, dynamic>{
  'active_members': instance.activeMembers,
  'today_visits': instance.todayVisits,
  'window_revenue_minor': instance.windowRevenueMinor,
  'class_capacity_total': instance.classCapacityTotal,
  'class_confirmed_total': instance.classConfirmedTotal,
  'class_occupancy_pct': instance.classOccupancyPct,
  'expiring_entitlements_7d': instance.expiringEntitlements7d,
};
