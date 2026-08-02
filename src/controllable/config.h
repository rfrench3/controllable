
#include <kconfiggroup.h>
#include <ksharedconfig.h>
#include <qstring.h>

using namespace Qt::StringLiterals;

struct Kcminputrc {
    Kcminputrc()
    {
        auto config = KSharedConfig::openConfig(u"kcminputrc"_s);

        RepeatDelay = config->group(u"Keyboard"_s).readEntry(u"RepeatDelay"_s, u"600"_s).toInt();
        RepeatRate = config->group(u"Keyboard"_s).readEntry(u"RepeatRate"_s, u"25"_s).toInt();

        KeyRepeat = config->group(u"Keyboard"_s).readEntry(u"KeyRepeat"_s, u""_s).isEmpty();
    };

    bool KeyRepeat;
    int RepeatDelay;
    int RepeatRate;
};
static Kcminputrc kcminputrc;
