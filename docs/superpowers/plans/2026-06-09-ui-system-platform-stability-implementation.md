# UI System and Platform Stability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a unified mobile-first UI system for the five main GuguPet tabs and fix the Web/Windows blockers needed for stable UI verification.

**Architecture:** Implement the system-first approach from `docs/superpowers/specs/2026-06-09-ui-system-platform-stability-design.md`. Start by isolating platform bootstrapping and database migration safety, then add shared design tokens/components, wrap the app in a responsive frame, apply the system to the five main tabs, and finish with screenshot plus automated verification.

**Tech Stack:** Flutter 3.38.5, Dart 3.10.4, Provider, sqflite/sqflite_common_ffi, Flutter widget tests.

**Completion Record:** Implemented on 2026-06-09 in branch `codex/ui-system-platform-stability`. The completed scope includes platform-safe bootstrap, idempotent database migration runner, unified visual tokens, responsive app frame, bottom navigation refresh, five-tab UI normalization, Web local-persistence guards for UI verification, targeted Flutter tests, targeted analysis, and Browser screenshot verification. Remaining non-blocking items are tracked in `docs/技术债务记录.md`.

---

## File Structure

- Modify: `app/lib/core/theme/app_colors.dart` - add approved token names while preserving existing color aliases during migration.
- Modify: `app/lib/core/theme/app_shadows.dart` - add token-aligned shadows.
- Modify: `app/lib/core/theme/app_theme.dart` - wire the approved token values into ThemeData.
- Create: `app/lib/core/platform/platform_capabilities.dart` - expose Web-safe platform booleans and feature flags.
- Create: `app/lib/core/bootstrap/app_bootstrap.dart` - initialize Flutter bindings, platform database factory, config services, and security services safely per platform.
- Modify: `app/lib/main.dart` - delegate bootstrapping to `AppBootstrap` and remove direct `dart:io Platform` use from the entrypoint.
- Modify: `app/lib/data/datasources/local/database_migration.dart` - expose migration metadata and SQL through a runner-friendly API.
- Create: `app/lib/data/datasources/local/database_migration_runner.dart` - execute guarded/idempotent migration statements.
- Modify: `app/lib/data/datasources/local/database_helper.dart` - use the migration runner for create/upgrade paths.
- Create: `app/lib/shared/widgets/app_surface_card.dart` - shared card surface.
- Create: `app/lib/shared/widgets/app_section_header.dart` - shared section heading.
- Create: `app/lib/shared/widgets/app_pill.dart` - shared pill/tag component.
- Create: `app/lib/shared/widgets/app_icon_badge.dart` - shared icon badge and simplified pet badge.
- Create: `app/lib/shared/widgets/app_empty_state.dart` - shared empty-state component.
- Create: `app/lib/shared/widgets/app_primary_button.dart` - shared primary button.
- Create: `app/lib/shared/widgets/app_search_field.dart` - shared search field.
- Create: `app/lib/shared/widgets/responsive_app_frame.dart` - centered desktop/Web frame and mobile pass-through.
- Modify: `app/lib/shared/widgets/app_bottom_nav_bar.dart` - use new tokens and surface.
- Modify: `app/lib/shared/widgets/widgets.dart` - export new shared widgets.
- Modify: `app/lib/pages/home/home_page.dart` - wrap scaffold with `ResponsiveAppFrame`, use normalized navigation labels/icons, and keep tab behavior.
- Modify: `app/lib/features/confide/pages/confide_page.dart` - apply tokenized background/surfaces while preserving pet logic.
- Modify: `app/lib/features/jobs/pages/jobs_page.dart` - use shared search, pills, headers, and background.
- Modify: `app/lib/features/jobs/widgets/job_card.dart` - use `AppSurfaceCard`, `AppPill`, and `AppPrimaryButton`.
- Modify: `app/lib/features/park/pages/park_page_enhanced.dart` - replace broad green background with tokenized structured sections.
- Modify: `app/lib/features/park/widgets/park_user_card.dart` - use simplified pet badge/icon colors.
- Modify: `app/lib/features/columns/pages/columns_page.dart` - reduce archive palette dominance and use shared surfaces.
- Modify: `app/lib/features/columns/widgets/column_card.dart` - normalize card, price, and trial action styling.
- Modify: `app/lib/features/columns/widgets/bottom_cta.dart` - align CTA with token system.
- Modify: `app/lib/features/profile/pages/profile_page.dart` - use shared background/section styles.
- Modify: `app/lib/features/profile/widgets/user_info_card.dart` - normalize user card.
- Modify: `app/lib/features/profile/widgets/stat_summary_card.dart` - normalize stats.
- Modify: `app/lib/features/profile/widgets/vip_status_card.dart` - use warm accent inside global card language.
- Modify: `app/lib/features/profile/widgets/menu_list.dart` - normalize menu surfaces.
- Create: `app/test/core/platform/platform_capabilities_test.dart` - verify platform flags can be read without `dart:io` crashes.
- Create: `app/test/data/database_migration_runner_test.dart` - cover existing-table and repeated-index scenarios.
- Create: `app/test/shared/widgets/design_system_widgets_test.dart` - smoke-test shared components.
- Create: `app/test/shared/widgets/responsive_app_frame_test.dart` - verify mobile and wide layout constraints.
- Create: `app/test/pages/home_page_smoke_test.dart` - verify the home page can switch all five tabs with mocked providers where needed.
- Update: `docs/技术债务记录.md` - add any verification limitations found during implementation.

---

### Task 1: Web-Safe Bootstrap and Platform Capabilities

**Files:**
- Create: `app/lib/core/platform/platform_capabilities.dart`
- Create: `app/lib/core/bootstrap/app_bootstrap.dart`
- Modify: `app/lib/main.dart`
- Test: `app/test/core/platform/platform_capabilities_test.dart`

- [ ] **Step 1: Write the platform capabilities test**

Create `app/test/core/platform/platform_capabilities_test.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/core/platform/platform_capabilities.dart';

void main() {
  group('PlatformCapabilities', () {
    test('exposes feature flags without throwing', () {
      expect(() => PlatformCapabilities.current, returnsNormally);

      final capabilities = PlatformCapabilities.current;
      expect(capabilities.isWeb, kIsWeb);
      expect(capabilities.supportsLocalSqlite, isA<bool>());
      expect(capabilities.supportsDeviceSecurityChecks, isA<bool>());
      expect(capabilities.supportsLocalNotifications, isA<bool>());
    });
  });
}
```

- [ ] **Step 2: Run the failing test**

Run:

```powershell
flutter test test/core/platform/platform_capabilities_test.dart
```

Expected: FAIL because `PlatformCapabilities` does not exist.

- [ ] **Step 3: Add Web-safe platform capabilities**

Create `app/lib/core/platform/platform_capabilities.dart`:

```dart
import 'package:flutter/foundation.dart';

/// Describes platform features used during app startup and UI verification.
///
/// This keeps Web builds away from direct dart:io platform checks while giving
/// native platforms access to local SQLite, notifications, and security checks.
class PlatformCapabilities {
  const PlatformCapabilities({
    required this.isWeb,
    required this.isWindows,
    required this.isLinux,
    required this.isAndroid,
    required this.isIOS,
    required this.supportsLocalSqlite,
    required this.supportsDeviceSecurityChecks,
    required this.supportsLocalNotifications,
  });

  final bool isWeb;
  final bool isWindows;
  final bool isLinux;
  final bool isAndroid;
  final bool isIOS;
  final bool supportsLocalSqlite;
  final bool supportsDeviceSecurityChecks;
  final bool supportsLocalNotifications;

  static PlatformCapabilities get current {
    final platform = defaultTargetPlatform;
    final isNativeDesktop = !kIsWeb &&
        (platform == TargetPlatform.windows || platform == TargetPlatform.linux);
    final isNativeMobile = !kIsWeb &&
        (platform == TargetPlatform.android || platform == TargetPlatform.iOS);

    return PlatformCapabilities(
      isWeb: kIsWeb,
      isWindows: !kIsWeb && platform == TargetPlatform.windows,
      isLinux: !kIsWeb && platform == TargetPlatform.linux,
      isAndroid: !kIsWeb && platform == TargetPlatform.android,
      isIOS: !kIsWeb && platform == TargetPlatform.iOS,
      supportsLocalSqlite: !kIsWeb,
      supportsDeviceSecurityChecks: isNativeMobile || isNativeDesktop,
      supportsLocalNotifications: isNativeMobile,
    );
  }
}
```

- [ ] **Step 4: Run platform capabilities test**

Run:

```powershell
flutter test test/core/platform/platform_capabilities_test.dart
```

Expected: PASS.

- [ ] **Step 5: Add app bootstrap service**

Create `app/lib/core/bootstrap/app_bootstrap.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../platform/platform_capabilities.dart';
import '../services/ai_auto_config_service.dart';
import '../services/app_strings.dart';
import '../services/business_config_service.dart';
import '../services/security_service.dart';
import '../services/test_admin_initializer.dart';
import '../services/test_user_initializer.dart';
import '../services/theme_service.dart';
import '../../features/feedback/services/error_capture_service.dart';

/// Coordinates startup services in a platform-safe order.
///
/// Web builds intentionally skip native-only setup so the UI can be browsed for
/// verification even when local persistence and device services are unavailable.
class AppBootstrap {
  const AppBootstrap({this.capabilities});

  final PlatformCapabilities? capabilities;

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    final currentCapabilities = capabilities ?? PlatformCapabilities.current;
    _initializeSqlite(currentCapabilities);

    ErrorCaptureService().initialize();
    await _initializeSecurity(currentCapabilities);
    await AppStrings.initialize();
    await BusinessConfigService.initialize();
    await ThemeService.initialize();

    if (currentCapabilities.supportsLocalSqlite) {
      await TestUserInitializer.initialize();
      await TestAdminInitializer.initialize();
      TestAdminInitializer.printAllTestAccountsInfo();
    }

    await AIAutoConfigService.initialize();
  }

  void _initializeSqlite(PlatformCapabilities capabilities) {
    if (capabilities.isWindows || capabilities.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<void> _initializeSecurity(PlatformCapabilities capabilities) async {
    if (!capabilities.supportsDeviceSecurityChecks) {
      return;
    }

    try {
      final securityService = SecurityService();
      await securityService.initialize();
      await securityService.isDeviceSecure();
    } catch (error) {
      debugPrint('[Security] Startup security check skipped after error: $error');
    }
  }
}
```

- [ ] **Step 6: Delegate `main.dart` startup to `AppBootstrap`**

Modify the top of `app/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/theme/theme.dart';
```

Replace the current `main()` body and remove `_initializeSecurity()`:

```dart
void main() async {
  await const AppBootstrap().initialize();
  runApp(const JobPetApp());
}
```

Also remove imports for `dart:io`, `sqflite_common_ffi`, `SecurityService`, `TestUserInitializer`, `TestAdminInitializer`, `AppStrings`, `BusinessConfigService`, `ThemeService`, `AIAutoConfigService`, and `ErrorCaptureService` from `main.dart` when they are only used by the deleted startup code.

- [ ] **Step 7: Run analysis and targeted tests**

Run:

```powershell
flutter analyze lib/main.dart lib/core/platform/platform_capabilities.dart lib/core/bootstrap/app_bootstrap.dart
flutter test test/core/platform/platform_capabilities_test.dart
```

Expected: analysis has no new errors in touched files; test PASS.

- [ ] **Step 8: Commit**

```powershell
git add app/lib/main.dart app/lib/core/platform/platform_capabilities.dart app/lib/core/bootstrap/app_bootstrap.dart app/test/core/platform/platform_capabilities_test.dart
git commit -m "fix: add platform-safe app bootstrap"
```

---

### Task 2: Idempotent Database Migration Runner

**Files:**
- Modify: `app/lib/data/datasources/local/database_migration.dart`
- Create: `app/lib/data/datasources/local/database_migration_runner.dart`
- Modify: `app/lib/data/datasources/local/database_helper.dart`
- Test: `app/test/data/database_migration_runner_test.dart`

- [ ] **Step 1: Write migration runner tests**

Create `app/test/data/database_migration_runner_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/data/datasources/local/database_migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
  });

  tearDown(() async {
    await db.close();
  });

  test('skips CREATE TABLE when the table already exists', () async {
    await db.execute('CREATE TABLE wish_envelopes (id TEXT PRIMARY KEY)');

    await DatabaseMigrationRunner.runSqlList(db, [
      '''
      CREATE TABLE wish_envelopes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL
      )
      ''',
    ]);

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      ['wish_envelopes'],
    );
    expect(tables, hasLength(1));
  });

  test('skips CREATE INDEX when the index already exists', () async {
    await db.execute('CREATE TABLE users (user_id TEXT PRIMARY KEY)');
    await db.execute('CREATE INDEX idx_users_user_id ON users (user_id)');

    await DatabaseMigrationRunner.runSqlList(db, [
      'CREATE INDEX idx_users_user_id ON users (user_id)',
    ]);

    final indexes = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index' AND name = ?",
      ['idx_users_user_id'],
    );
    expect(indexes, hasLength(1));
  });

  test('skips ALTER TABLE ADD COLUMN when the column already exists', () async {
    await db.execute('CREATE TABLE users (user_id TEXT PRIMARY KEY, account TEXT)');

    await DatabaseMigrationRunner.runSqlList(db, [
      'ALTER TABLE users ADD COLUMN account TEXT',
    ]);

    final columns = await db.rawQuery('PRAGMA table_info(users)');
    final accountColumns = columns.where((column) => column['name'] == 'account');
    expect(accountColumns, hasLength(1));
  });
}
```

- [ ] **Step 2: Run the failing migration tests**

Run:

```powershell
flutter test test/data/database_migration_runner_test.dart
```

Expected: FAIL because `DatabaseMigrationRunner` does not exist.

- [ ] **Step 3: Add migration runner**

Create `app/lib/data/datasources/local/database_migration_runner.dart`:

```dart
import 'package:sqflite/sqflite.dart';

/// Executes migration SQL in a guarded way for development databases that may
/// already contain part of a migration from an older build.
class DatabaseMigrationRunner {
  const DatabaseMigrationRunner._();

  static Future<void> runSqlList(DatabaseExecutor executor, List<String> sqlList) async {
    for (final rawSql in sqlList) {
      final sql = rawSql.trim();
      if (sql.isEmpty) continue;
      if (await _shouldSkip(executor, sql)) continue;
      await executor.execute(sql);
    }
  }

  static Future<bool> _shouldSkip(DatabaseExecutor executor, String sql) async {
    final normalized = sql.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();

    final tableName = _matchName(sql, RegExp(r'CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([A-Za-z_][A-Za-z0-9_]*)', caseSensitive: false));
    if (tableName != null && normalized.startsWith('CREATE TABLE')) {
      return _tableExists(executor, tableName);
    }

    final indexName = _matchName(sql, RegExp(r'CREATE\s+(?:UNIQUE\s+)?INDEX\s+(?:IF\s+NOT\s+EXISTS\s+)?([A-Za-z_][A-Za-z0-9_]*)', caseSensitive: false));
    if (indexName != null && normalized.startsWith('CREATE INDEX') || normalized.startsWith('CREATE UNIQUE INDEX')) {
      return _indexExists(executor, indexName!);
    }

    final alterMatch = RegExp(
      r'ALTER\s+TABLE\s+([A-Za-z_][A-Za-z0-9_]*)\s+ADD\s+COLUMN\s+([A-Za-z_][A-Za-z0-9_]*)',
      caseSensitive: false,
    ).firstMatch(sql);
    if (alterMatch != null) {
      return _columnExists(executor, alterMatch.group(1)!, alterMatch.group(2)!);
    }

    return false;
  }

  static String? _matchName(String sql, RegExp pattern) {
    return pattern.firstMatch(sql)?.group(1);
  }

  static Future<bool> _tableExists(DatabaseExecutor executor, String tableName) async {
    final result = await executor.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  static Future<bool> _indexExists(DatabaseExecutor executor, String indexName) async {
    final result = await executor.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index' AND name = ?",
      [indexName],
    );
    return result.isNotEmpty;
  }

  static Future<bool> _columnExists(
    DatabaseExecutor executor,
    String tableName,
    String columnName,
  ) async {
    final columns = await executor.rawQuery('PRAGMA table_info($tableName)');
    return columns.any((column) => column['name'] == columnName);
  }
}
```

Correct the precedence bug in `_shouldSkip` before running tests:

```dart
if (indexName != null &&
    (normalized.startsWith('CREATE INDEX') ||
        normalized.startsWith('CREATE UNIQUE INDEX'))) {
  return _indexExists(executor, indexName);
}
```

- [ ] **Step 4: Route DatabaseHelper through the runner**

Modify `app/lib/data/datasources/local/database_helper.dart`:

```dart
import 'database_migration_runner.dart';
```

Replace each migration SQL loop in `_onCreate` and `_onUpgrade`:

```dart
await DatabaseMigrationRunner.runSqlList(txn, migration);
```

Keep the surrounding transaction and logging.

- [ ] **Step 5: Run migration tests**

Run:

```powershell
flutter test test/data/database_migration_runner_test.dart
```

Expected: PASS.

- [ ] **Step 6: Run affected datasource tests**

Run:

```powershell
flutter test test/datasources/vector_memory_datasource_test.dart test/integration/rag_integration_test.dart
```

Expected: PASS or existing unrelated failures documented in `docs/技术债务记录.md`.

- [ ] **Step 7: Commit**

```powershell
git add app/lib/data/datasources/local/database_helper.dart app/lib/data/datasources/local/database_migration_runner.dart app/test/data/database_migration_runner_test.dart docs/技术债务记录.md
git commit -m "fix: make database migrations idempotent"
```

---

### Task 3: Design Tokens and Shared Components

**Files:**
- Modify: `app/lib/core/theme/app_colors.dart`
- Modify: `app/lib/core/theme/app_shadows.dart`
- Modify: `app/lib/core/theme/app_theme.dart`
- Create: `app/lib/shared/widgets/app_surface_card.dart`
- Create: `app/lib/shared/widgets/app_section_header.dart`
- Create: `app/lib/shared/widgets/app_pill.dart`
- Create: `app/lib/shared/widgets/app_icon_badge.dart`
- Create: `app/lib/shared/widgets/app_empty_state.dart`
- Create: `app/lib/shared/widgets/app_primary_button.dart`
- Create: `app/lib/shared/widgets/app_search_field.dart`
- Modify: `app/lib/shared/widgets/widgets.dart`
- Test: `app/test/shared/widgets/design_system_widgets_test.dart`

- [ ] **Step 1: Write shared widget smoke tests**

Create `app/test/shared/widgets/design_system_widgets_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/core/theme/theme.dart';
import 'package:jobpet/shared/widgets/widgets.dart';

void main() {
  testWidgets('design system widgets render primary UI primitives', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              const AppSectionHeader(title: '今日任务', subtitle: '咕咕陪你推进求职'),
              const AppSurfaceCard(child: Text('card body')),
              const AppPill(label: '推荐'),
              const AppIconBadge(icon: Icons.work_outline),
              const AppEmptyState(
                icon: Icons.notifications_none,
                title: '暂无通知',
                message: '有新消息时会第一时间通知你',
              ),
              AppPrimaryButton(label: '立即投递', onPressed: () {}),
              AppSearchField(
                controller: TextEditingController(),
                hintText: '搜索职位',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('今日任务'), findsOneWidget);
    expect(find.text('card body'), findsOneWidget);
    expect(find.text('推荐'), findsOneWidget);
    expect(find.text('暂无通知'), findsOneWidget);
    expect(find.text('立即投递'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run failing shared widget test**

Run:

```powershell
flutter test test/shared/widgets/design_system_widgets_test.dart
```

Expected: FAIL because shared widgets do not exist.

- [ ] **Step 3: Add approved color tokens**

In `app/lib/core/theme/app_colors.dart`, add these constants near the top while keeping old constants:

```dart
static const Color backgroundDefault = Color(0xFFF8F7FC);
static const Color backgroundSubtle = Color(0xFFF1F3FA);
static const Color textDefault = Color(0xFF202136);
static const Color textSecondary = Color(0xFF71758A);
static const Color textTertiary = Color(0xFFA1A4B5);
static const Color textInverse = Color(0xFFFFFFFF);
static const Color textFill = Color(0xFFEEF1FF);
static const Color iconDefault = Color(0xFF5F6FEB);
static const Color iconSecondary = Color(0xFF7B7E91);
static const Color iconFill = Color(0xFFEEF1FF);
static const Color surfaceDefault = Color(0xFFFFFFFF);
static const Color surfaceSecondary = Color(0xFFF4F5FB);
static const Color surfaceFill = Color(0xCCFFFFFF);
static const Color brandPrimary = Color(0xFF5F6FEB);
static const Color brandSoft = Color(0xFFDDE3FF);
static const Color accentWarm = Color(0xFFF5B84B);
static const Color accentGrowth = Color(0xFF59C783);
static const Color borderDefault = Color(0xFFE4E6EF);
static const Color dividerDefault = Color(0xFFECEEF5);
```

Add compatibility aliases:

```dart
static const Color background = surfaceDefault;
static const Color foreground = textDefault;
static const Color primary = brandPrimary;
static const Color mutedForeground = textSecondary;
static const Color cardBackground = surfaceDefault;
static const Color divider = dividerDefault;
static const Color indigo500 = brandPrimary;
```

If duplicate names already exist, update their values instead of adding duplicate declarations.

- [ ] **Step 4: Add shared component files**

Create `app/lib/shared/widgets/app_surface_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Shared card surface used by main-tab pages.
class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      onTap: onTap,
      child: content,
    );
  }
}
```

Create `app/lib/shared/widgets/app_section_header.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Standard section heading with optional action.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headingMedium.copyWith(color: AppColors.textDefault)),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
```

Create `app/lib/shared/widgets/app_pill.dart`, `app_icon_badge.dart`, `app_empty_state.dart`, `app_primary_button.dart`, and `app_search_field.dart` with the same token rules:

```dart
// app_pill.dart
class AppPill extends StatelessWidget {
  const AppPill({super.key, required this.label, this.icon, this.selected = false});
  final String label;
  final IconData? icon;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: selected ? AppColors.brandPrimary : AppColors.textFill,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 14, color: selected ? AppColors.textInverse : AppColors.iconDefault), const SizedBox(width: 4)],
      Text(label, style: AppTypography.labelMedium.copyWith(color: selected ? AppColors.textInverse : AppColors.textSecondary)),
    ]),
  );
}
```

```dart
// app_icon_badge.dart
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({super.key, required this.icon, this.count, this.backgroundColor, this.iconColor, this.onTap});
  final IconData icon;
  final int? count;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Stack(clipBehavior: Clip.none, children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: backgroundColor ?? AppColors.iconFill, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        child: Icon(icon, color: iconColor ?? AppColors.iconDefault, size: 22),
      ),
      if (count != null && count! > 0)
        Positioned(right: -4, top: -4, child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(color: AppColors.accentWarm, shape: BoxShape.circle),
          child: Text(count! > 9 ? '9+' : '$count', style: AppTypography.labelSmall.copyWith(color: AppColors.textInverse)),
        )),
    ]),
  );
}
```

```dart
// app_empty_state.dart
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AppIconBadge(icon: icon, backgroundColor: AppColors.surfaceSecondary, iconColor: AppColors.iconSecondary),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: AppTypography.headingSmall.copyWith(color: AppColors.textDefault)),
        const SizedBox(height: AppSpacing.sm),
        Text(message, textAlign: TextAlign.center, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        if (action != null) ...[const SizedBox(height: AppSpacing.md), action!],
      ]),
    ),
  );
}
```

```dart
// app_primary_button.dart
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onPressed,
    icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandPrimary,
      foregroundColor: AppColors.textInverse,
      minimumSize: const Size.fromHeight(AppSpacing.buttonHeightLg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
    ),
  );
}
```

```dart
// app_search_field.dart
class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, required this.controller, required this.hintText, this.onChanged});
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search, color: AppColors.iconSecondary),
      filled: true,
      fillColor: AppColors.surfaceDefault,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg), borderSide: BorderSide.none),
    ),
  );
}
```

Add necessary imports at the top of each file:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
```

- [ ] **Step 5: Export shared widgets**

Modify `app/lib/shared/widgets/widgets.dart`:

```dart
export 'glass_container.dart';
export 'animated_star.dart';
export 'app_bottom_nav_bar.dart';
export 'app_surface_card.dart';
export 'app_section_header.dart';
export 'app_pill.dart';
export 'app_icon_badge.dart';
export 'app_empty_state.dart';
export 'app_primary_button.dart';
export 'app_search_field.dart';
export 'responsive_app_frame.dart';
```

The `responsive_app_frame.dart` file is created in Task 4. If Task 3 is run alone before Task 4, omit that export until Task 4.

- [ ] **Step 6: Run shared widget test**

Run:

```powershell
flutter test test/shared/widgets/design_system_widgets_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```powershell
git add app/lib/core/theme app/lib/shared/widgets app/test/shared/widgets/design_system_widgets_test.dart
git commit -m "feat: add shared UI design system"
```

---

### Task 4: Responsive Frame and Navigation

**Files:**
- Create: `app/lib/shared/widgets/responsive_app_frame.dart`
- Modify: `app/lib/shared/widgets/app_bottom_nav_bar.dart`
- Modify: `app/lib/shared/widgets/widgets.dart`
- Modify: `app/lib/pages/home/home_page.dart`
- Test: `app/test/shared/widgets/responsive_app_frame_test.dart`

- [ ] **Step 1: Write responsive frame tests**

Create `app/test/shared/widgets/responsive_app_frame_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/shared/widgets/responsive_app_frame.dart';

void main() {
  testWidgets('wide layouts constrain the app content width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveAppFrame(
          child: SizedBox.expand(key: Key('content')),
        ),
      ),
    );

    final contentSize = tester.getSize(find.byKey(const Key('content')));
    expect(contentSize.width, lessThanOrEqualTo(430));
  });

  testWidgets('mobile layouts use full available width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveAppFrame(
          child: SizedBox.expand(key: Key('content')),
        ),
      ),
    );

    final contentSize = tester.getSize(find.byKey(const Key('content')));
    expect(contentSize.width, 390);
  });
}
```

- [ ] **Step 2: Run failing responsive test**

Run:

```powershell
flutter test test/shared/widgets/responsive_app_frame_test.dart
```

Expected: FAIL because `ResponsiveAppFrame` does not exist.

- [ ] **Step 3: Add responsive frame**

Create `app/lib/shared/widgets/responsive_app_frame.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Mobile-first frame that keeps the app full width on phones and presents a
/// polished centered container on desktop and wide Web.
class ResponsiveAppFrame extends StatelessWidget {
  const ResponsiveAppFrame({
    super.key,
    required this.child,
    this.maxContentWidth = 430,
    this.desktopBreakpoint = 700,
  });

  final Widget child;
  final double maxContentWidth;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= desktopBreakpoint;
        if (!isWide) return child;

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.backgroundDefault, AppColors.brandSoft],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDefault,
                    border: Border.all(color: AppColors.borderDefault),
                    boxShadow: AppShadows.floating,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Normalize bottom nav**

Modify `app/lib/shared/widgets/app_bottom_nav_bar.dart`:

```dart
decoration: BoxDecoration(
  color: AppColors.surfaceFill,
  boxShadow: AppShadows.button,
  border: const Border(
    top: BorderSide(color: AppColors.dividerDefault, width: 1),
  ),
),
```

Change icon/text colors:

```dart
color: isActive ? AppColors.brandPrimary : AppColors.iconSecondary,
```

- [ ] **Step 5: Wrap HomePage with the responsive frame**

Modify `app/lib/pages/home/home_page.dart` so `build` returns:

```dart
return ResponsiveAppFrame(
  child: Scaffold(
    backgroundColor: AppColors.backgroundDefault,
    body: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _pages[_currentIndex],
    ),
    bottomNavigationBar: AppBottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: _navItems,
    ),
  ),
);
```

Ensure imports include:

```dart
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
```

- [ ] **Step 6: Export responsive frame**

Modify `app/lib/shared/widgets/widgets.dart`:

```dart
export 'responsive_app_frame.dart';
```

- [ ] **Step 7: Run tests**

Run:

```powershell
flutter test test/shared/widgets/responsive_app_frame_test.dart test/shared/widgets/design_system_widgets_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit**

```powershell
git add app/lib/shared/widgets app/lib/pages/home/home_page.dart app/test/shared/widgets/responsive_app_frame_test.dart
git commit -m "feat: add responsive app frame"
```

---

### Task 5: Apply the System to the Five Main Tabs

**Files:**
- Modify: `app/lib/features/confide/pages/confide_page.dart`
- Modify: `app/lib/features/jobs/pages/jobs_page.dart`
- Modify: `app/lib/features/jobs/widgets/job_card.dart`
- Modify: `app/lib/features/park/pages/park_page_enhanced.dart`
- Modify: `app/lib/features/park/widgets/park_user_card.dart`
- Modify: `app/lib/features/columns/pages/columns_page.dart`
- Modify: `app/lib/features/columns/widgets/column_card.dart`
- Modify: `app/lib/features/columns/widgets/bottom_cta.dart`
- Modify: `app/lib/features/profile/pages/profile_page.dart`
- Modify: `app/lib/features/profile/widgets/user_info_card.dart`
- Modify: `app/lib/features/profile/widgets/stat_summary_card.dart`
- Modify: `app/lib/features/profile/widgets/vip_status_card.dart`
- Modify: `app/lib/features/profile/widgets/menu_list.dart`
- Test: `app/test/pages/home_page_smoke_test.dart`

- [ ] **Step 1: Write home page smoke test**

Create `app/test/pages/home_page_smoke_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/core/theme/theme.dart';
import 'package:jobpet/shared/widgets/app_bottom_nav_bar.dart';

void main() {
  testWidgets('bottom nav uses five main destinations', (tester) async {
    final items = const [
      NavItem(label: '倾诉室', icon: Icons.pets_outlined, activeIcon: Icons.pets),
      NavItem(label: '求职', icon: Icons.work_outline, activeIcon: Icons.work),
      NavItem(label: '公园', icon: Icons.park_outlined, activeIcon: Icons.park),
      NavItem(label: '专栏', icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book),
      NavItem(label: '我的', icon: Icons.person_outline, activeIcon: Icons.person),
    ];

    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: selected,
              items: items,
              onTap: (index) => setState(() => selected = index),
            ),
          ),
        ),
      ),
    );

    expect(find.text('倾诉室'), findsOneWidget);
    expect(find.text('求职'), findsOneWidget);
    expect(find.text('公园'), findsOneWidget);
    expect(find.text('专栏'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(selected, 4);
  });
}
```

- [ ] **Step 2: Run smoke test**

Run:

```powershell
flutter test test/pages/home_page_smoke_test.dart
```

Expected: PASS after Task 4. If labels are still mojibake in source, update `HomePage._navItems` to the clear Chinese labels shown in this test.

- [ ] **Step 3: Update Jobs card and page to shared primitives**

In `app/lib/features/jobs/widgets/job_card.dart`, replace root container with:

```dart
return AppSurfaceCard(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  padding: const EdgeInsets.all(AppSpacing.lg),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(),
      const SizedBox(height: 4),
      _buildSalary(),
      const SizedBox(height: 8),
      _buildCompany(),
      const SizedBox(height: 12),
      _buildTags(),
      const SizedBox(height: 16),
      _buildFooter(),
    ],
  ),
);
```

Use `AppPill` in `_buildTags()`:

```dart
return AppPill(label: tag.toString());
```

Use `AppPrimaryButton` for details:

```dart
SizedBox(
  width: 112,
  height: 36,
  child: AppPrimaryButton(label: '查看详情', onPressed: onTap),
)
```

In `app/lib/features/jobs/pages/jobs_page.dart`, set root background to `AppColors.backgroundDefault`, replace custom search field with `AppSearchField`, and replace category containers with `AppPill(selected: ...)`.

- [ ] **Step 4: Update Profile widgets to shared card language**

For `user_info_card.dart`, `stat_summary_card.dart`, `vip_status_card.dart`, and `menu_list.dart`:

- Use `AppSurfaceCard` as the outer surface.
- Use `AppIconBadge` for leading icons.
- Use `AppPill` for job status/VIP labels.
- Use `AppColors.textDefault`, `textSecondary`, `brandPrimary`, and `accentWarm`.

In `profile_page.dart`, replace hardcoded `Color(0xFFF8F7FC)` with `AppColors.backgroundDefault`.

- [ ] **Step 5: Update Park page structure**

In `park_page_enhanced.dart`:

- Replace `_buildBackground()` with a tokenized gradient:

```dart
return Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.backgroundDefault, AppColors.backgroundSubtle],
    ),
  ),
);
```

- Replace header buttons with `AppIconBadge`.
- Replace emoji zone icons with Material icons and labels.
- Add an `AppSurfaceCard` guide section under the online users area:

```dart
AppSurfaceCard(
  child: AppSectionHeader(
    title: '今日森林动态',
    subtitle: '看看同伴的新进展，也给自己一点求职能量',
    trailing: AppPill(label: '去看看', icon: Icons.arrow_forward),
  ),
)
```

- Use simplified badge styling in `park_user_card.dart`.

- [ ] **Step 6: Update Columns archive theme**

In `columns_page.dart`:

- Keep the archive banner but reduce page-wide brown dominance.
- Set the main page background to `AppColors.backgroundDefault`.
- Use `AppColors.accentWarm` for archive highlights and `AppColors.textDefault` for main text.
- Replace section title container with `AppSectionHeader`.

In `column_card.dart` and `bottom_cta.dart`:

- Use `AppSurfaceCard`.
- Use `AppPill` for category labels.
- Use `AppPrimaryButton` or token-aligned filled buttons for trial/CTA actions.

- [ ] **Step 7: Update Confide page surfaces**

In `confide_page.dart`:

- Keep pet animation and response behavior.
- Ensure the root background uses a low-saturation gradient derived from `backgroundDefault`, `brandSoft`, and `surfaceDefault`.
- Use `AppSurfaceCard` or tokenized `Container` styles for top status and input areas.
- Replace freeform accent colors with `brandPrimary`, `accentWarm`, and `accentGrowth`.

- [ ] **Step 8: Run page smoke and analysis**

Run:

```powershell
flutter analyze lib/features/confide/pages/confide_page.dart lib/features/jobs/pages/jobs_page.dart lib/features/jobs/widgets/job_card.dart lib/features/park/pages/park_page_enhanced.dart lib/features/columns/pages/columns_page.dart lib/features/profile/pages/profile_page.dart
flutter test test/pages/home_page_smoke_test.dart test/shared/widgets/design_system_widgets_test.dart test/shared/widgets/responsive_app_frame_test.dart
```

Expected: no new analysis errors in touched files; tests PASS.

- [ ] **Step 9: Commit**

```powershell
git add app/lib/features app/test/pages/home_page_smoke_test.dart
git commit -m "feat: apply unified UI system to main tabs"
```

---

### Task 6: Verification, Screenshots, and Debt Updates

**Files:**
- Modify: `docs/技术债务记录.md`
- Do not modify: `README.md` in this plan. Keep the implementation focused on UI, platform stability, and the existing debt document.

- [ ] **Step 1: Run targeted automated checks**

Run:

```powershell
flutter test test/core/platform/platform_capabilities_test.dart test/data/database_migration_runner_test.dart test/shared/widgets/design_system_widgets_test.dart test/shared/widgets/responsive_app_frame_test.dart test/pages/home_page_smoke_test.dart
flutter analyze lib/main.dart lib/core/platform lib/core/bootstrap lib/shared/widgets lib/pages/home lib/features/jobs lib/features/profile
```

Expected: targeted tests PASS; analysis has no new errors in touched areas.

- [ ] **Step 2: Verify Web can open main UI**

Run:

```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 53123
```

Expected:

- Browser can open `http://127.0.0.1:53123`.
- App no longer crashes with `Unsupported operation: Platform._operatingSystem`.
- Five main tabs are reachable for visual inspection.

- [ ] **Step 3: Verify Windows launch**

Run:

```powershell
flutter run -d windows
```

Expected:

- App opens to the main page.
- No startup failure from `wish_envelopes already exists`.
- Desktop window shows centered mobile-first app frame when wide enough.

- [ ] **Step 4: Capture screenshots**

Use the in-app Browser for Web screenshots if available, or Windows screenshots for the desktop run. Capture:

- Confide tab
- Jobs tab
- Park tab
- Columns tab
- Profile tab

Check:

- Navigation is consistent.
- No abnormal blank space.
- No obvious text overflow.
- Cards, pills, buttons, and icon badges share the same visual language.

- [ ] **Step 5: Update debt document with verification results**

In `docs/技术债务记录.md`, add a section:

```markdown
## 2026-06-09 UI 优化验证后记录

| 问题 | 影响范围 | 是否阻塞当前 UI 验证 | 建议优先级 | 后续建议 |
| --- | --- | --- | --- | --- |
| Web 仍不是正式发布平台 | Web | 否 | P2 | 若要发布 Web，补完整持久化、通知、设备能力替代方案 |
| 桌面端仍是移动优先容器，不是完整桌面工作台 | Windows、宽屏 Web | 否 | P2 | 后续扩展 `ResponsiveAppFrame` 为双栏布局 |
```

If Step 1-4 reveal extra verification failures, append one table row per failure with the concrete command or screen where it was observed. If no extra failures are observed, append this row:

```markdown
| 本轮验证未发现额外阻塞项 | UI 验证 | 否 | P3 | 保持现有债务列表，后续按专项任务继续治理 |
```

- [ ] **Step 6: Commit verification updates**

```powershell
git add docs/技术债务记录.md
git commit -m "docs: record UI verification debt"
```

---

## Self-Review

Spec coverage:

- Design tokens: Task 3.
- Shared components: Task 3.
- Responsive frame and mobile-first desktop polish: Task 4.
- Five main tabs: Task 5.
- Web startup blocker: Task 1 and Task 6.
- Windows/database startup blocker: Task 2 and Task 6.
- Verification: Task 6.
- Debt document updates: Task 6.

The plan is written as concrete executable tasks. If a task reveals existing unrelated test failures, record those in `docs/技术债务记录.md` instead of expanding this implementation scope.
