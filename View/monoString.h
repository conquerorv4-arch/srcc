#pragma once

#include <string>

struct monoString {
    void* klass;
    void* monitor;
    int length;
    char chars[1];

    int getLength() {
        return length;
    }

    wchar_t* getChars() {
        return (wchar_t*)chars;
    }

    std::string toCPPString() {
        std::wstring ws(getChars(), getLength());
        return std::string(ws.begin(), ws.end());
    }
};
