
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

///
class MetaDataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: YoutubeValueBuilder(
        buildWhen: (o, n) {
          return o.metaData != n.metaData ||
              o.playbackQuality != n.playbackQuality;
        },
        builder: (context, value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Text('Título', value.metaData.title),
              // const SizedBox(height: 5),
              // _Text('Canal', value.metaData.author),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Text('Duración', '${value.metaData.duration.inMinutes.toString()} min'),
                  const Spacer(),
                  Text('Velocidad :', style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),),
                  const SizedBox(width: 5),
                  YoutubeValueBuilder(
                    builder: (context, value) {
                      return DropdownButton(
                        isDense: true,
                        value: value.playbackRate,
                        style:  Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                        dropdownColor: Colors.black.withOpacity(0.7),
                        iconEnabledColor: Colors.white,
                        items: PlaybackRate.all.map(
                              (rate) => DropdownMenuItem(
                            child: Text(
                              '${rate}x',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            value: rate,
                          ),
                        )
                            .toList(),
                        onChanged: (double? newValue) {
                          if (newValue != null) {
                            context.ytController.setPlaybackRate(newValue);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Text extends StatelessWidget {
  final String title;
  final String value;

  const _Text(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$title : ',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 12
        ),
        children: [
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontSize: 12
            ),
          ),
        ],
      ),
    );
  }
}