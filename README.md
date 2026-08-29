# ATS Mini

![](docs/source/_static/esp32-si4732-ui-theme.jpg)

This firmware is for use on the SI4732 (ESP32-S3) Mini/Pocket Receiver

Based on the following sources:

* Volos Projects:    https://github.com/VolosR/TEmbedFMRadio
* PU2CLR, Ricardo:   https://github.com/pu2clr/SI4735
* Ralph Xavier:      https://github.com/ralphxavier/SI4735
* Goshante:          https://github.com/goshante/ats20_ats_ex
* G8PTN, Dave:       https://github.com/G8PTN/ATS_MINI

## Synchronous AM fork

The `-sync` fork adds optional synchronous AM reception in USB and LSB modes.
Its implementation was developed as a human-AI collaboration. Antonio
([@armegia](https://github.com/armegia)) identified the feature, selected
Goshante's ATS_EX v1.18 as the behavioral reference, made the product and
release decisions, and performed the OSPI hardware tests. OpenAI Codex analyzed
both codebases, implemented and documented the port, prepared the Arduino
CLI/Visual Studio Code build workflow, performed compile validation, integrated
later upstream releases, and prepared the release artifacts. Antonio reviewed
and accepted the resulting changes and maintains the fork.

The synchronous detector behavior itself is derived from Goshante's ATS_EX
firmware; its hardware and user-interface code was not copied into this
different target.

## Releases

Check out the [Releases](https://github.com/esp32-si4732/ats-mini/releases) page.

## Documentation

The hardware, software and flashing documentation is available at <https://esp32-si4732.github.io/ats-mini/>

## Discuss

* [GitHub Discussions](https://github.com/esp32-si4732/ats-mini/discussions) - the best place for feature requests, observations, sharing, etc.
* [TalkRadio Telegram Chat](https://t.me/talkradio/174172) - informal space to chat in Russian and English.
