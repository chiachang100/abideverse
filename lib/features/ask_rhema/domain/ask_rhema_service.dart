import 'ask_rhema_request.dart';
import 'ask_rhema_response.dart';

abstract interface class AskRhemaService {
  Future<AskRhemaResponse> ask(AskRhemaRequest request);
}
