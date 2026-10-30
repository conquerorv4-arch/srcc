#define IMGUI_DEFINE_MATH_OPERATORS
#define LocalPlayer g_LocalPlayer
#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/utsname.h>
#include "imgui.h"
#include "imgui_impl_metal.h"
#include "xor.h"
#include <cmath>
#include <vector>
#include <string>
#include <map>
#include "Tools.h"
#include "Vector3.h"
#include "Vector2.h"
#include "monoString.h"

// ============================================================
// UNREAL ENGINE SDK - DOĞRU INCLUDE SIRALAMASI (ƏVVƏL CORE, SONRA BASIC)
// ============================================================
#include "SDK/SHANKS_PUBGM_CoreUObject_structs.hpp"
#include "SDK/SHANKS_PUBGM_CoreUObject_classes.hpp"
#include "SDK/SHANKS_PUBGM_Basic_structs.hpp"
#include "SDK/SHANKS_PUBGM_Basic_classes.hpp"
#include "SDK/SHANKS_PUBGM_Engine_structs.hpp"
#include "SDK/SHANKS_PUBGM_Engine_classes.hpp"
#include "SDK/SHANKS_PUBGM_GameplayAbilities_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayAbilities_classes.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTags_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTags_classes.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTasks_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTasks_classes.hpp"
#include "SDK/SHANKS_PUBGM_Gameplay_structs.hpp"
#include "SDK/SHANKS_PUBGM_Gameplay_classes.hpp"
#include "SDK/SHANKS_PUBGM_UMG_structs.hpp"
#include "SDK/SHANKS_PUBGM_UMG_classes.hpp"
#include "SDK/SHANKS_PUBGM_ShadowTrackerExtra_structs.hpp"
#include "SDK/SHANKS_PUBGM_ShadowTrackerExtra_classes.hpp"

using namespace SDK;

@interface ImGuiDrawView : UIViewController <MTKViewDelegate> {
    MTKView *mtkView;
}
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
+ (void)showChange:(BOOL)arg1;
+ (BOOL)isChange;
@end

std::string getDeviceHWID() {
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    NSString *uuidString = [uuid UUIDString];
    return std::string([uuidString UTF8String]);
}

bool verifyKeyWithServer(std::string inputKey) {
    std::string hwid = getDeviceHWID();
    NSString *urlString = [NSString stringWithFormat:@"https://darkhxtekcu.site.je/check.php?key=%s&hwid=%s", inputKey.c_str(), hwid.c_str()];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return false;
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (json && [json[@"status"] isEqualToString:@"success"]) {
        return true;
    }
    return false;
}

void DrawWatermark() {
    ImGuiIO& io = ImGui::GetIO();
    ImVec2 screenSize = io.DisplaySize;
    ImVec2 textPos = ImVec2((screenSize.x - ImGui::CalcTextSize("DARK IOS").x) * 0.5f, 15.0f);
    ImGuiWindowFlags flags = ImGuiWindowFlags_NoBackground | 
                             ImGuiWindowFlags_NoTitleBar | 
                             ImGuiWindowFlags_NoInputs | 
                             ImGuiWindowFlags_AlwaysAutoResize;
    ImGui::SetNextWindowPos(textPos);
    ImGui::Begin("WatermarkOverlay", nullptr, flags);
    ImDrawList* drawList = ImGui::GetWindowDrawList();
    ImVec2 pos = ImGui::GetCursorScreenPos();
    drawList->AddText(ImVec2(pos.x + 1, pos.y + 1), IM_COL32(0, 0, 0, 255), "DARK IOS");
    drawList->AddText(pos, IM_COL32(255, 255, 255, 255), "DARK IOS");
    ImGui::End();
}

void (*orig_shoot_event)(USTExtraShootWeaponComponent*, FVector, FRotator, ASTExtraShootWeapon*, int) = nullptr;
void (*orig_throw_grenade)(ASTExtraWeapon*, FVector, FRotator) = nullptr;
void (*orig_shoot_underbarrel)(ASTExtraWeapon*, FVector, FRotator) = nullptr;
void (*orig_process_event)(UObject*, UFunction*, void*) = nullptr;

uint64_t getBaseAddress(const char* n){for(int i=0;i<_dyld_image_count();i++){if(strstr(_dyld_get_image_name(i),n))return _dyld_get_image_vmaddr_slide(i);}return 0;}
uint64_t getRealOffset(uint64_t o){return getBaseAddress(ENCRYPT("ShadowTrackerExtra"))+o;}
long GetGlobalObjectsOffset(){return getRealOffset(0x10A7F93E0);}
TNameEntryArray* GetGlobalNames(){return ((TNameEntryArray*(*)())(getRealOffset(0x105014128)))();}
UWorld*GEWorld=0;int GWorldNum=0;TUObjectArray gobjects;
UWorld*GetFullWorld(){@try{if(GWorldNum==0){gobjects=UObject::GUObjectArray->ObjObjects;for(int i=0;i<gobjects.Num();i++){@try{if(auto o=gobjects.GetByIndex(i);o&&o->IsA(UEngine::StaticClass())){auto e=(UEngine*)o;if(e&&e->GameViewport){tslFont=e->MediumFont;auto v=e->GameViewport;if(v&&v->World){GEWorld=v->World;GWorldNum=i;return v->World;}}}}@catch(...){}}}else{@try{auto e=(UEngine*)gobjects.GetByIndex(GWorldNum);if(e){if(!tslFont&&e->MediumFont)tslFont=e->MediumFont;auto v=e->GameViewport;if(v&&v->World){GEWorld=v->World;return v->World;}}}@catch(...){GWorldNum=0;return GetFullWorld();}}}@catch(...){}return 0;}

template<class T>void GetAllActorsInGame(std::vector<T*>& a){@try{auto w=GetFullWorld();if(!w)return;auto s=(UGameplayStatics*)UGameplayStatics::StaticClass();if(!s)return;TArray<AActor*> arr;s->GetAllActorsOfClass((UObject*)w,T::StaticClass(),&arr);for(int i=0;i<arr.Num();i++){@try{if(arr[i])a.push_back((T*)arr[i]);}@catch(...){}}}@catch(...){}}

float FVectorSize(const FVector& v){return sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z);}
void NormalizeAngles(FRotator& a){while(a.Pitch>180)a.Pitch-=360;while(a.Pitch<-180)a.Pitch+=360;if(a.Pitch>89)a.Pitch=89;if(a.Pitch<-89)a.Pitch=-89;while(a.Yaw>180)a.Yaw-=360;while(a.Yaw<-180)a.Yaw+=360;a.Roll=0;}
FVector GetCameraLocation(ASTExtraPlayerController* pc){@try{if(pc&&pc->PlayerCameraManager)return pc->PlayerCameraManager->CameraCache.POV.Location;}@catch(...){}return FVector();}
FRotator GetCameraRotation(ASTExtraPlayerController* pc){@try{if(pc&&pc->PlayerCameraManager)return pc->PlayerCameraManager->CameraCache.POV.Rotation;}@catch(...){}return FRotator();}

std::wstring GetItemNameFromID(int id){
    static std::map<int,std::wstring> m={{101001,L"akm"},{101004,L"m416"},{101011,L"m762"},{103003,L"awm"}};
    auto it=m.find(id);if(it!=m.end())return it->second;
    return L"item #"+std::to_wstring(id);
}

void DrawLine(AHUD* h,FVector2D a,FVector2D b,float t,FLinearColor c){@try{if(h&&h->Canvas)h->Canvas->K2_DrawLine(a,b,t,c);}@catch(...){}}
void DrawText(AHUD* h,FString t,FVector2D p,FLinearColor c,bool cx){@try{if(h&&h->Canvas&&tslFont)h->Canvas->K2_DrawText(tslFont,t,p,c,1.f,FLinearColor(0,0,0,0),FVector2D(0,0),cx,false,false,FLinearColor(0,0,0,0));}@catch(...){}}

ASTExtraPlayerCharacter* FindBestTarget(float fov,float maxD,int bone,bool checkVis,bool closestFirst,FRotator& outRot){
    @try{
        if(!g_LocalPlayer||!g_PlayerController)return nullptr;
        std::vector<ASTExtraPlayerCharacter*>p;
        GetAllActorsInGame(p);
        ASTExtraPlayerCharacter*best=nullptr;
        float bestVal=FLT_MAX;
        FVector camLoc=GetCameraLocation(g_PlayerController);
        FRotator camRot=GetCameraRotation(g_PlayerController);
        for(auto e:p){
            if(!e||e->GetCurrentVehicle()||e->PlayerKey==g_LocalPlayer->PlayerKey||e->TeamID==g_LocalPlayer->TeamID||e->bDead||e->bHidden)continue;
            float dist=e->GetDistanceTo(g_LocalPlayer)/100.f;
            if(dist>maxD)continue;
            FVector bp=e->GetBonePos("Head",FVector(0,0,0));
            FVector dir=bp-camLoc;
            FRotator tr=UKismetMathLibrary::Conv_VectorToRotator(dir);
            NormalizeAngles(tr);
            float da=sqrt(pow(tr.Pitch-camRot.Pitch,2)+pow(tr.Yaw-camRot.Yaw,2));
            if(da>fov)continue;
            float val=closestFirst?dist:da;
            if(val<bestVal){bestVal=val;best=e;outRot=tr;}
        }
        return best;
    }@catch(...){return nullptr;}
}

float GetBulletSpeed(){
    @try{
        float bs=800;
        if(g_LocalPlayer && g_LocalPlayer->WeaponManagerComponent){
            auto cw=(ASTExtraShootWeapon*)g_LocalPlayer->WeaponManagerComponent->CurrentWeaponReplicated;
            if(cw && cw->ShootWeaponEntityComp) bs=cw->ShootWeaponEntityComp->BulletFireSpeed;
        }
        return bs;
    }@catch(...){return 800;}
}

void PredictTarget(FVector& tp,ASTExtraPlayerCharacter* t,FVector origin){
    @try{
        FVector vel=t->GetVelocity();
        float bs=GetBulletSpeed();
        float dist=FVectorSize(tp-origin);
        float tt=dist/bs;
        tp.X+=vel.X*tt;
        tp.Y+=vel.Y*tt;
        tp.Z+=vel.Z*tt;
    }@catch(...){}
}

bool HasWeaponEquipped(){
    @try{
        if(!g_LocalPlayer||!g_LocalPlayer->WeaponManagerComponent)return false;
        int slotVal=(int)g_LocalPlayer->WeaponManagerComponent->GetCurrentUsingPropSlot().GetValue();
        return(slotVal>=1&&slotVal<=3);
    }@catch(...){return false;}
}

void HookedShootEvent(USTExtraShootWeaponComponent* c,FVector s,FRotator r,ASTExtraShootWeapon* w,int u){
    @try{
        FRotator tr;
        ASTExtraPlayerCharacter* t=FindBestTarget(aim.silent_fov,aim.silent_distance,aim.silent_bone,aim.silent_vis_check,false,tr);
        if(!t||!aim.silent){if(orig_shoot_event)orig_shoot_event(c,s,r,w,u);return;}
        FVector tp=t->GetBonePos("Head",FVector(0,0,0));
        if(aim.prediction)PredictTarget(tp,t,s);
        FRotator nr=UKismetMathLibrary::Conv_VectorToRotator(tp-s);
        NormalizeAngles(nr);
        if(orig_shoot_event)orig_shoot_event(c,s,nr,w,u);
    }@catch(...){if(orig_shoot_event)orig_shoot_event(c,s,r,w,u);}
}

void HookedThrowGrenade(ASTExtraWeapon* w,FVector s,FRotator r){
    @try{if(orig_throw_grenade)orig_throw_grenade(w,s,r);}@catch(...){}
}

void HookedShootUnderbarrel(ASTExtraWeapon* w,FVector s,FRotator r){
    @try{if(orig_shoot_underbarrel)orig_shoot_underbarrel(w,s,r);}@catch(...){}
}

void SaveSettings(){
    NSUserDefaults* d=[NSUserDefaults standardUserDefaults];
    [d setBool:aim.enabled forKey:@"ae"];
    [d synchronize];
}

void LoadSettings(){
    NSUserDefaults* d=[NSUserDefaults standardUserDefaults];
    aim.enabled=[d boolForKey:@"ae"];
}

void RenderESP(AHUD* hud,int w,int h){
    @try{
        if(!tslFont){GetFullWorld();if(!tslFont)return;}
        auto s=(UGameplayStatics*)UGameplayStatics::StaticClass();
        auto world=GetFullWorld();
        ASTExtraPlayerController* pc=nullptr;
        if(world&&world->NetDriver&&world->NetDriver->ServerConnection)
            pc=(ASTExtraPlayerController*)world->NetDriver->ServerConnection->PlayerController;
        if(!pc)return;
        
        std::vector<ASTExtraPlayerCharacter*>pl;
        GetAllActorsInGame(pl);
        ASTExtraPlayerCharacter*lp=nullptr;
        for(auto p:pl)if(p&&p->PlayerKey==pc->PlayerKey){lp=p;break;}
        if(!lp)return;
        
        g_LocalPlayer=lp;
        g_PlayerController=pc;
        
        for(auto e:pl){
            if(!e||e==lp||e->bDead||e->bHidden)continue;
            float dist=e->GetDistanceTo(lp)/100.f;
            FVector pos=e->K2_GetActorLocation();
            FVector2D screenPos;
            if(s->ProjectWorldToScreen(pc, pos, false, &screenPos)){
                std::wstring distStr = std::to_wstring((int)dist) + L"m";
                DrawText(hud, FString(distStr.c_str()), screenPos, FLinearColor(1,1,1,1), true);
            }
        }
    }@catch(...){}
}
