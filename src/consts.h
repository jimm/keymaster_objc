#ifndef _CONSTS_
#define _CONSTS_

// Mostly used for Connection values.
#define UNDEFINED -1

#define is_channel(b) ((b) >= 0x80 && (b) < 0xF0)
#define is_realtime(b) ((b) >= 0xF8)
// is_note includes POLY_PRESSURE
#define is_note(b) ((b) >= 0x80 && (b) < 0xB0)
#define channel(b) ((b) & 0x0F)

// MIDI constants

// Number of MIDI channels
#define MIDI_CHANNELS 16
// Number of note per MIDI channel
#define NOTES_PER_CHANNEL 128

// Standard MIDI File meta event defs

#define META_EVENT 0xff
#define META_SEQ_NUM 0x00
#define META_TEXT 0x01
#define META_COPYRIGHT 0x02
#define META_SEQ_NAME 0x03
#define META_INSTRUMENT 0x04
#define META_LYRIC 0x05
#define META_MARKER 0x06
#define META_CUE 0x07
#define META_MIDI_CHAN_PREFIX 0x20
#define META_TRACK_END 0x2f
#define META_SET_TEMPO 0x51
#define META_SMPTE 0x54
#define META_TIME_SIG 0x58
#define META_KEY_SIG 0x59
#define META_SEQ_SPECIF 0x7f

// Channel messages

// Note, val
#define NOTE_OFF 0x80
// Note, val
#define NOTE_ON 0x90
// Note, val
#define POLY_PRESSURE 0xA0
// Controller #, val
#define CONTROLLER 0xB0
// Program number
#define PROGRAM_CHANGE 0xC0
// Channel pressure
#define CHANNEL_PRESSURE 0xD0
// LSB, MSB
#define PITCH_BEND 0xE0

// System common messages

// System exclusive start
#define SYSEX 0xF0
// Beats from top: LSB/MSB 6 ticks 1 beat
#define SONG_POINTER 0xF2
// Val number of song
#define SONG_SELECT 0xF3
// Tune request
#define TUNE_REQUEST 0xF6
// End of system exclusive
#define EOX 0xF7

// System realtime messages

// MIDI clock (24 per quarter note)
#define CLOCK 0xF8
// Sequence start
#define START 0xFA
// Sequence continue
#define CONTINUE 0xFB
// Sequence stop
#define STOP 0xFC
// Active sensing (sent every 300 ms when nothing else being sent)
#define ACTIVE_SENSE 0xFE
// System reset
#define SYSTEM_RESET 0xFF

// Controller numbers
// 0 - 31 continuous, LSB
// 32 - 63 continuous, MSB
// 64 - 97 switches
#define CC_BANK_SELECT 0
#define CC_MOD_WHEEL 1
#define CC_BREATH_CONTROLLER 2
#define CC_FOOT_CONTROLLER 4
#define CC_PORTAMENTO_TIME 5
#define CC_DATA_ENTRY_LSB 6
#define CC_VOLUME 7
#define CC_BALANCE 8
#define CC_PAN 10
#define CC_EXPRESSION_CONTROLLER 11
#define CC_GEN_PURPOSE_1 16
#define CC_GEN_PURPOSE_2 17
#define CC_GEN_PURPOSE_3 18
#define CC_GEN_PURPOSE_4 19

// [32 - 63] are LSB for [0 - 31]
#define CC_DATA_ENTRY_MSB 38

// Momentaries:

#define CC_SUSTAIN 64
#define CC_PORTAMENTO 65
#define CC_SUSTENUTO 66
#define CC_SOFT_PEDAL 67
#define CC_HOLD_2 69
#define CC_GEN_PURPOSE_5 50
#define CC_GEN_PURPOSE_6 51
#define CC_GEN_PURPOSE_7 52
#define CC_GEN_PURPOSE_8 53
#define CC_TREMELO_DEPTH 92
#define CC_CHORUS_DEPTH 93
#define CC_DETUNE_DEPTH 94
#define CC_PHASER_DEPTH 95
#define CC_DATA_INCREMENT 96
#define CC_DATA_DECREMENT 97
#define CC_NREG_PARAM_LSB 98
#define CC_NREG_PARAM_MSB 99
#define CC_REG_PARAM_LSB 100
#define CC_REG_PARAM_MSB 101

// Channel mode message values

// Val 0 == off, 0x7f == on
#define CM_LOCAL_CONTROL 0x7A
#define CM_ALL_NOTES_OFF 0x7B // Val must be 0
#define CM_OMNI_MODE_OFF 0x7C // Val must be 0
#define CM_OMNI_MODE_ON 0x7D  // Val must be 0
#define CM_MONO_MODE_ON 0x7E  // Val # chans
#define CM_POLY_MODE_ON 0x7F  // Val must be 0

@class NSDictionary;
extern NSDictionary *constNameValues;

/*
// Controller names
char *CONTROLLER_NAMES[128];

// General MIDI patch names
char *GM_PATCH_NAMES[128];

// GM drum notes start at 35 (C), so subtrack GM_DRUM_NOTE_LOWEST from your
// note number before using this array.
#define GM_DRUM_NOTE_LOWEST 35

// General MIDI drum channel note names.
char *GM_DRUM_NOTE_NAMES[47];
*/

#endif // _CONSTS_
