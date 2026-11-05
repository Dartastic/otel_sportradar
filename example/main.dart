// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_sportradar/otel_sportradar.dart';

/// Traces Sportradar calls with OpenTelemetry.
///
/// `otel_sportradar` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Sportradar call in
/// [tracedSportradar]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'sportradar-example');

  // Wraps a Sportradar API call in a CLIENT span.
  final sportradarId = await tracedSportradar<String>(
    operation: 'schedule.get',
    invoke: () async {
      // Make the Sportradar call here, then report what it returned.
      const id = 'sportradar_8f3a2c';
      return const SportradarCallResult(
          value: id,
          result: SportradarResult(
              environment: 'production',
              sport: 'nfl',
              league: 'nfl',
              accessLevel: 't1',
              languageCode: 'en',
              format: 'json',
              surface: 'gameFeed',
              seasonId: 'season_8f3a2c',
              gameId: 'game_8f3a2c',
              competitionId: 'competition_8f3a2c',
              teamId: 'team_8f3a2c',
              playerId: 'player_8f3a2c',
              eventCount: 3,
              scoreboardLive: false,
              locale: 'us',
              responseBytes: 512,
              qpsRemaining: 1,
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 200));
    },
  );
  OTelLog.info('tracedSportradar schedule.get returned $sportradarId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutSportradarInstrumentationAsync.
  await runWithoutSportradarInstrumentationAsync(
    () => tracedSportradar<String>(
      operation: 'schedule.get',
      invoke: () async {
        const id = 'sportradar_8f3a2c';
        return const SportradarCallResult(
            value: id,
            result: SportradarResult(
                environment: 'production',
                sport: 'nfl',
                league: 'nfl',
                accessLevel: 't1',
                languageCode: 'en',
                format: 'json',
                surface: 'gameFeed',
                seasonId: 'season_8f3a2c',
                gameId: 'game_8f3a2c',
                competitionId: 'competition_8f3a2c',
                teamId: 'team_8f3a2c',
                playerId: 'player_8f3a2c',
                eventCount: 3,
                scoreboardLive: false,
                locale: 'us',
                responseBytes: 512,
                qpsRemaining: 1,
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
