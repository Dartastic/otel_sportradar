// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_sportradar_suppression.dart';

const _tracerName = 'dartastic_otel_libs_sportradar';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class SportradarResult {
  const SportradarResult({
    this.environment,
    this.sport,
    this.league,
    this.accessLevel,
    this.languageCode,
    this.format,
    this.surface,
    this.seasonId,
    this.gameId,
    this.competitionId,
    this.teamId,
    this.playerId,
    this.eventCount,
    this.scoreboardLive,
    this.locale,
    this.responseBytes,
    this.qpsRemaining,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `production`, `trial`, `simulation`.
  final String? environment;

  /// `nfl`, `nba`, `mlb`, `nhl`, `soccer`, `tennis`, `mma`, `golf`,
  /// `cricket`, `racing`, `f1`, `nascar`, `tabletennis`, `volleyball`,
  /// `handball`, `cs2`, `dota2`, `lol`, `valorant`.
  final String? sport;

  /// `nfl`, `nba`, `epl`, `ncaa`, ...
  final String? league;

  /// `t1`, `t2`, `t3` (Sportradar access tier — affects rate limit + data).
  final String? accessLevel;

  /// ISO 639 language (`en`, `es`, `de`, ...).
  final String? languageCode;

  /// `json`, `xml`.
  final String? format;

  /// `gameFeed`, `boxscore`, `summary`, `schedule`, `standings`,
  /// `seasonRoster`, `teamProfile`, `playerProfile`, `playByPlay`,
  /// `eventStream`, `imageManifest`, `odds`, `injuries`, `news`,
  /// `pushFeed`, `webSocket`.
  final String? surface;

  final String? seasonId;
  final String? gameId;
  final String? competitionId;
  final String? teamId;
  final String? playerId;

  /// Number of events in a feed payload.
  final int? eventCount;

  /// Scoreboard call hit a live (in-progress) game.
  final bool? scoreboardLive;

  /// `us`, `eu`, `intl`.
  final String? locale;

  final int? responseBytes;

  /// Remaining QPS on the Sportradar API key (header).
  final int? qpsRemaining;

  /// Sportradar error code.
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class SportradarCallResult<T> {
  const SportradarCallResult({required this.value, this.result});
  final T value;
  final SportradarResult? result;
}

/// Wraps a Sportradar API call in a CLIENT span. [operation] is one of
/// `schedule.get`, `season.schedule`, `gameFeed.get`, `boxscore.get`,
/// `summary.get`, `playByPlay.get`, `injuries.get`, `news.get`,
/// `imageManifest.get`, `roster.get`, `team.profile`, `team.statistics`,
/// `player.profile`, `player.statistics`, `standings.get`,
/// `rankings.get`, `odds.preMatch`, `odds.live`, `odds.player`,
/// `eventStream.subscribe`, `pushFeed.connect`, `pushFeed.disconnect`,
/// `webSocket.subscribe`.
Future<T> tracedSportradar<T>({
  required String operation,
  required Future<SportradarCallResult<T>> Function() invoke,
}) async {
  if (sportradarInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'sportradar',
    'rpc.method': operation,
    'sportradar.operation': operation,
  };

  final span = _tracer().startSpan(
    'sportradar $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.environment != null) {
        extras.add(OTel.attributeString(
          'sportradar.environment',
          res.environment!,
        ));
      }
      if (res.sport != null) {
        extras.add(OTel.attributeString('sportradar.sport', res.sport!));
      }
      if (res.league != null) {
        extras.add(OTel.attributeString('sportradar.league', res.league!));
      }
      if (res.accessLevel != null) {
        extras.add(OTel.attributeString(
          'sportradar.access_level',
          res.accessLevel!,
        ));
      }
      if (res.languageCode != null) {
        extras.add(OTel.attributeString(
          'sportradar.language',
          res.languageCode!,
        ));
      }
      if (res.format != null) {
        extras.add(OTel.attributeString('sportradar.format', res.format!));
      }
      if (res.surface != null) {
        extras.add(OTel.attributeString(
          'sportradar.surface',
          res.surface!,
        ));
      }
      if (res.seasonId != null) {
        extras.add(OTel.attributeString(
          'sportradar.season.id',
          res.seasonId!,
        ));
      }
      if (res.gameId != null) {
        extras.add(OTel.attributeString('sportradar.game.id', res.gameId!));
      }
      if (res.competitionId != null) {
        extras.add(OTel.attributeString(
          'sportradar.competition.id',
          res.competitionId!,
        ));
      }
      if (res.teamId != null) {
        extras.add(OTel.attributeString('sportradar.team.id', res.teamId!));
      }
      if (res.playerId != null) {
        extras.add(OTel.attributeString(
          'sportradar.player.id',
          res.playerId!,
        ));
      }
      if (res.eventCount != null) {
        extras.add(OTel.attributeInt(
          'sportradar.event.count',
          res.eventCount!,
        ));
      }
      if (res.scoreboardLive != null) {
        extras.add(OTel.attributeBool(
          'sportradar.scoreboard.live',
          res.scoreboardLive!,
        ));
      }
      if (res.locale != null) {
        extras.add(OTel.attributeString('sportradar.locale', res.locale!));
      }
      if (res.responseBytes != null) {
        extras.add(OTel.attributeInt(
          'sportradar.response.bytes',
          res.responseBytes!,
        ));
      }
      if (res.qpsRemaining != null) {
        extras.add(OTel.attributeInt(
          'sportradar.qps.remaining',
          res.qpsRemaining!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'sportradar.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Sportradar ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'sportradar.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Sportradar HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
