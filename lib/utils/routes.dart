import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/clients/client_list_screen.dart';
import '../screens/clients/client_form_screen.dart';
import '../models/client.dart';
import '../screens/projects/project_list_screen.dart';
import '../screens/projects/project_form_screen.dart';
import '../models/project.dart';
import '../screens/tasks/task_list_screen.dart';
import '../screens/tasks/task_form_screen.dart';
import '../screens/users/user_list_screen.dart';
import '../screens/users/user_form_screen.dart';
import '../models/task.dart';
import '../models/user.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  GoRouter get router => GoRouter(
        initialLocation: '/',
        refreshListenable: authProvider,
        redirect: (context, state) {
          final loggingIn = state.uri.path == '/login' || state.uri.path == '/register';

          if (!authProvider.isAuthenticated) {
            return loggingIn ? null : '/login';
          }

          if (loggingIn) {
            return '/';
          }

          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/clients',
            builder: (context, state) => const ClientListScreen(),
          ),
          GoRoute(
            path: '/clients/new',
            builder: (context, state) => const ClientFormScreen(),
          ),
          GoRoute(
            path: '/clients/edit',
            builder: (context, state) {
              final client = state.extra as Client;
              return ClientFormScreen(client: client);
            },
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectListScreen(),
          ),
          GoRoute(
            path: '/projects/new',
            builder: (context, state) => const ProjectFormScreen(),
          ),
          GoRoute(
            path: '/projects/edit',
            builder: (context, state) {
              final project = state.extra as Project;
              return ProjectFormScreen(project: project);
            },
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) {
              final projectId = state.uri.queryParameters['projectId'];
              final projectName = state.uri.queryParameters['projectName'];
              return TaskListScreen(
                projectId: projectId != null ? int.tryParse(projectId) : null,
                projectName: projectName,
              );
            },
          ),
          GoRoute(
            path: '/tasks/new',
            builder: (context, state) {
              final projectId = state.extra as int?;
              return TaskFormScreen(projectId: projectId);
            },
          ),
          GoRoute(
            path: '/tasks/edit',
            builder: (context, state) {
              final task = state.extra as AppTask;
              return TaskFormScreen(task: task);
            },
          ),
          GoRoute(
            path: '/tasks/form',
            builder: (context, state) => TaskFormScreen(task: state.extra as AppTask?),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UserListScreen(),
          ),
          GoRoute(
            path: '/users/form',
            builder: (context, state) => UserFormScreen(user: state.extra as User?),
          ),
        ],
      );
}
