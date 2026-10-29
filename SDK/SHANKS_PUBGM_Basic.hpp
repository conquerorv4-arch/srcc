#pragma once

#include <string>
#include <vector>

namespace SDK {
    struct FString {
        PWSTR Data;
        int ArrayNum;
        int ArrayMax;

        bool IsValid() const {
            return Data != nullptr;
        }

        std::string ToString() const {
            if (!IsValid()) return "";
            std::wstring ws(Data, ArrayNum);
            return std::string(ws.begin(), ws.end());
        }
    };

    template<typename T>
    struct TArray {
        T* Data;
        int NumCounts;
        int MaxCounts;

        int Num() const { return NumCounts; }
        int Max() const { return MaxCounts; }
        
        T operator[](int i) const { return Data[i]; }
    };

    struct FName {
        int ComparisonIndex;
        int Number;

        bool IsValid() const {
            return ComparisonIndex != 0;
        }
    };
}
