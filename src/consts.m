#import <Foundation/NSObject.h>
#import <strings.h>
#import <consts.h>
#import <stdlib.h>              // for atoi and strn*

// Yes, searching these lists to find the corresponding value is O(n).
// However, it only happens at start-up when reading a .km file. Speed is
// not an issue.

static const char *statusNames[128] = {
    "NOTE_OFF",                 // 0x80
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    "NOTE_ON",                  // 0x90
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    "POLY_PRESSURE",            // 0xa0
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    "CONTROLLER",               // 0xb0
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    "PROGRAM_CHANGE",           // 0xc0
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    "CHANNEL_PRESSURE",         // 0xd0
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    "PITCH_BEND",               // 0xe0
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    "SYSEX",
    0,
    "SONG_POINTER",
    "SONG_SELECT",
    0, 0,
    "TUNE_REQUEST",
    "EOX",
    "CLOCK",
    0,
    "START",
    "CONTINUE",
    "STOP",
    0,
    "ACTIVE_SENSE",
    "SYSTEM_RESET"
};

struct cc_desc {
    char *name;
    Byte value;
};

static const struct cc_desc ccNames[128] = {
    {"CC_BANK_SELECT", 0},
    {"CC_MOD_WHEEL", 1},
    {"CC_BREATH_CONTROLLER", 2},
    {"CC_FOOT_CONTROLLER", 4},
    {"CC_PORTAMENTO_TIME", 5},
    {"CC_DATA_ENTRY_LSB", 6},
    {"CC_VOLUME", 7},
    {"CC_BALANCE", 8},
    {"CC_PAN", 10},
    {"CC_EXPRESSION_CONTROLLER", 11},
    {"CC_GEN_PURPOSE_1", 16},
    {"CC_GEN_PURPOSE_2", 17},
    {"CC_GEN_PURPOSE_3", 18},
    {"CC_GEN_PURPOSE_4", 19},

// [32 - 63] are LSB for [0 - 31]
    {"CC_DATA_ENTRY_MSB", 38},

// Momentaries:

    {"CC_SUSTAIN", 64},
    {"CC_PORTAMENTO", 65},
    {"CC_SUSTENUTO", 66},
    {"CC_SOFT_PEDAL", 67},
    {"CC_HOLD_2", 69},
    {"CC_GEN_PURPOSE_5", 50},
    {"CC_GEN_PURPOSE_6", 51},
    {"CC_GEN_PURPOSE_7", 52},
    {"CC_GEN_PURPOSE_8", 53},
    {"CC_TREMELO_DEPTH", 92},
    {"CC_CHORUS_DEPTH", 93},
    {"CC_DETUNE_DEPTH", 94},
    {"CC_PHASER_DEPTH", 95},
    {"CC_DATA_INCREMENT", 96},
    {"CC_DATA_DECREMENT", 97},
    {"CC_NREG_PARAM_LSB", 98},
    {"CC_NREG_PARAM_MSB", 99},
    {"CC_REG_PARAM_LSB", 100},
    {"CC_REG_PARAM_MSB", 101},

// Channel mode message values

// Val 0 == off, 0x7f == on
    {"CM_LOCAL_CONTROL", 0x7A},
    {"CM_ALL_NOTES_OFF", 0x7B}, // Val must be 0
    {"CM_OMNI_MODE_OFF", 0x7C}, // Val must be 0
    {"CM_OMNI_MODE_ON", 0x7D},  // Val must be 0
    {"CM_MONO_MODE_ON", 0x7E},  // Val # chans
    {"CM_POLY_MODE_ON", 0x7F},  // Val must be 0

    {0, 0}                      // END MARKER
};

// Maps name to a status byte. If name ends with ",N" where N is a number,
// then N-1 is added to that status byte.
//
// Returns UNDEFINED if not found.
int statusFromName(const char *name) {
    int nameLen = strlen(name);
    int i;
    for (i = 0; i < 128; ++i) {
        if (statusNames[i] == 0)
            continue;
        int snLen = strlen(statusNames[i]);
        if (strncasecmp(statusNames[i], name, snLen) == 0) {
            int statusByte = 0x80 + i;
            if (nameLen > snLen+1 && name[snLen] == ':') { // read channel number
                int oneBasedChan = atoi(name + snLen + 1);
                if (oneBasedChan >= 1 && oneBasedChan <= MIDI_CHANNELS)
                    statusByte += oneBasedChan - 1;
            }
            return statusByte;
        }
    }
    return UNDEFINED;
}

// Returns UNDEFINED if not found.
int ccFromName(const char *name) {
    int i;
    for (i = 0; ccNames[i].name != 0; ++i) {
        const struct cc_desc *ccd = &ccNames[i];
        if (strncasecmp(ccd->name, name, strlen(ccd->name)) == 0)
            return ccd->value;
    }
    return UNDEFINED;
}
