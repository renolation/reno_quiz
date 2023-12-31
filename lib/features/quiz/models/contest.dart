//class Contest {
class Contests {
  final Contest past;
  final Contest live;
  final Contest upcoming;
  Contests({required this.live, required this.past, required this.upcoming});
  static Contests fromJson(var json) {
    return Contests(
      live: Contest.fromJson(json['live_contest']),
      past: Contest.fromJson(json['past_contest']),
      upcoming: Contest.fromJson(json['upcoming_contest']),
    );
  }
}

class Contest {
  final String errorMessage;
  final List<ContestDetails> contestDetails;
  Contest({required this.contestDetails, required this.errorMessage});

  static Contest fromJson(var json) {
    final hasError = json['error'] as bool;
    final temContestDetails = hasError ? [] : json['data'] as List;
    return Contest(
        contestDetails:
            temContestDetails.map((e) => ContestDetails.fromJson(e)).toList(),
        errorMessage: hasError ? json['message'] : "");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = errorMessage;

    data['data'] = contestDetails.map((v) => v.toJson()).toList();

    return data;
  }
}

class ContestDetails {
  String? id;
  String? name;
  String? startDate;
  String? endDate;
  String? description;
  String? image;
  String? entry;
  String? prizeStatus;
  String? dateCreated;
  String? status;
  List? points;
  String? topUsers;
  String? participants;
  bool? showDescription = false;

  ContestDetails(
      {this.id,
      this.name,
      this.startDate,
      this.endDate,
      this.description,
      this.image,
      this.entry,
      this.prizeStatus,
      this.dateCreated,
      this.status,
      this.points,
      this.topUsers,
      this.participants,
      this.showDescription});

  ContestDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    description = json['description'];
    image = json['image'];
    entry = json['entry'];
    prizeStatus = json['prize_status'];
    dateCreated = json['date_created'];
    status = json['status'];
    points = json['points'];
    topUsers = json['top_users'];
    participants = json['participants'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['description'] = description;
    data['image'] = image;
    data['entry'] = entry;
    data['prize_status'] = prizeStatus;
    data['date_created'] = dateCreated;
    data['status'] = status;
    data['points'] = points;
    data['top_users'] = topUsers;
    data['participants'] = participants;
    return data;
  }
}
