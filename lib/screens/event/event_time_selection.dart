import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_location_app/common_components/invite_card.dart';
import 'package:atsign_location_app/common_components/text_tile_repeater.dart';
import 'package:atsign_location_app/common_components/tiles/text_tile.dart';
import 'package:atsign_location_app/models/enums_model.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class EventTimeSelection extends StatefulWidget {
  final String title;
  final List<String> options;
  final EventNotificationModel eventNotificationModel;
  final ValueChanged<dynamic> onSelectionChanged;
  final bool isStartTime;

  EventTimeSelection(
      {this.title,
      @required this.eventNotificationModel,
      this.onSelectionChanged,
      @required this.options,
      this.isStartTime = false});
  @override
  _EventTimeSelectionState createState() => _EventTimeSelectionState();
}

class _EventTimeSelectionState extends State<EventTimeSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          InviteCard(
            event: widget.eventNotificationModel.title,
            // invitedPeopleCount: '10 people invited',
            timeAndDate:
                '${timeOfDayToString(widget.eventNotificationModel.event.startTime)} on ${dateToString(widget.eventNotificationModel.event.date)}',
          ),
          SizedBox(height: 10),
          Divider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.title != null
                    ? Text(widget.title, style: CustomTextStyles().grey16)
                    : SizedBox(),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: widget.options.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        height: 50,
                        child: InkWell(
                          onTap: () {
                            switch (index) {
                              case 0:
                                widget.onSelectionChanged(widget.isStartTime
                                    ? LOC_START_TIME_ENUM.TWO_HOURS
                                    : LOC_END_TIME_ENUM.TEN_MIN);
                                break;
                              case 1:
                                widget.onSelectionChanged(widget.isStartTime
                                    ? LOC_START_TIME_ENUM.SIXTY_HOURS
                                    : LOC_END_TIME_ENUM
                                        .AFTER_EVERY_ONE_REACHED);
                                break;
                              case 2:
                                widget.onSelectionChanged(widget.isStartTime
                                    ? LOC_START_TIME_ENUM.THIRTY_HOURS
                                    : LOC_END_TIME_ENUM.AT_EOD);
                                break;
                            }
                          },
                          child: TextTile(title: widget.options[index]),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            // TextTileRepeater(
            //   title: widget.title,
            //   options: [
            //     '2 hours before the event',
            //     '60 hours before the event',
            //     '30 hours before the event'
            //   ],
            // ),
          )
        ],
      ),
    );
  }
}
