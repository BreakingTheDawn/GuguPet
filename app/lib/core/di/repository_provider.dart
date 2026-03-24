import '../../data/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/interaction_repository.dart';
import '../../data/repositories/interaction_repository_impl.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../data/repositories/column_repository.dart';
import '../../data/repositories/column_repository_impl.dart';

class RepositoryProvider {
  static final RepositoryProvider _instance = RepositoryProvider._internal();
  factory RepositoryProvider() => _instance;
  RepositoryProvider._internal();

  UserRepository? _userRepository;
  InteractionRepository? _interactionRepository;
  JobRepository? _jobRepository;
  ColumnRepository? _columnRepository;

  UserRepository get userRepository {
    _userRepository ??= UserRepositoryImpl();
    return _userRepository!;
  }

  InteractionRepository get interactionRepository {
    _interactionRepository ??= InteractionRepositoryImpl();
    return _interactionRepository!;
  }

  JobRepository get jobRepository {
    _jobRepository ??= JobRepositoryImpl();
    return _jobRepository!;
  }

  ColumnRepository get columnRepository {
    _columnRepository ??= ColumnRepositoryImpl();
    return _columnRepository!;
  }

  void reset() {
    _userRepository = null;
    _interactionRepository = null;
    _jobRepository = null;
    _columnRepository = null;
  }
}

final repositoryProvider = RepositoryProvider();
