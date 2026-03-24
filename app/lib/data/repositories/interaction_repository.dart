import '../models/interaction.dart';

abstract class InteractionRepository {
  Future<List<Interaction>> getInteractions(String userId);
  Future<void> saveInteraction(Interaction interaction);
  Future<void> deleteInteraction(String id);
  Future<int> getInteractionCount(String userId);
  Future<List<Interaction>> getRecentInteractions(String userId, int limit);
}
