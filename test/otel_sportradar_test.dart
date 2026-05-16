// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_sportradar/otel_sportradar.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_sportradar-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('schedule.get records sport + access tier + qps', () async {
    await tracedSportradar<String>(
      operation: 'schedule.get',
      invoke: () async => const SportradarCallResult(
        value: 'ok',
        result: SportradarResult(
          environment: 'production',
          sport: 'nfl',
          accessLevel: 't2',
          languageCode: 'en',
          format: 'json',
          surface: 'schedule',
          eventCount: 16,
          qpsRemaining: 980,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('sportradar schedule.get')!);
    expect(a['sportradar.sport'], 'nfl');
    expect(a['sportradar.access_level'], 't2');
    expect(a['sportradar.qps.remaining'], 980);
  });

  test('boxscore.get records game id + live flag', () async {
    await tracedSportradar<String>(
      operation: 'boxscore.get',
      invoke: () async => const SportradarCallResult(
        value: 'ok',
        result: SportradarResult(
          sport: 'nba',
          gameId: 'g_1',
          scoreboardLive: true,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('sportradar boxscore.get')!);
    expect(a['sportradar.scoreboard.live'], true);
  });

  test('rate limit 429 sets span error', () async {
    await tracedSportradar<String>(
      operation: 'gameFeed.get',
      invoke: () async => const SportradarCallResult(
        value: 'ok',
        result: SportradarResult(statusCode: 429, qpsRemaining: 0),
      ),
    );
    expect(
      spans.findSpanByName('sportradar gameFeed.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutSportradarInstrumentationAsync(() async {
      await tracedSportradar<String>(
        operation: 'news.get',
        invoke: () async => const SportradarCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('sportradar '), isEmpty);
  });
}
