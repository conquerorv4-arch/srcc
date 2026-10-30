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
// UNREAL ENGINE SDK - DOĞRU INCLUDE SIRALAMASI
// Sıralama KRİTİK: CoreUObject -> Engine -> Diğer Modüller
// ============================================================

// --- 1. TEMEL TİPLER (UObject, UClass, TArray, TMap vs.) ---
#include "SDK/SHANKS_PUBGM_CoreUObject_structs.hpp"
#include "SDK/SHANKS_PUBGM_CoreUObject_classes.hpp"

// --- 2. ENGINE (UActorComponent, AActor, UWorld vs.) ---
#include "SDK/SHANKS_PUBGM_Engine_structs.hpp"
#include "SDK/SHANKS_PUBGM_Engine_classes.hpp"

// --- 3. GAMEPLAY MODÜLLERİ (UGameplayStatics, UKismetMathLibrary vs.) ---
#include "SDK/SHANKS_PUBGM_GameplayAbilities_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayAbilities_classes.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTags_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTags_classes.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTasks_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTasks_classes.hpp"
#include "SDK/SHANKS_PUBGM_Gameplay_structs.hpp"
#include "SDK/SHANKS_PUBGM_Gameplay_classes.hpp"

// --- 4. UMG / UI ---
#include "SDK/SHANKS_PUBGM_UMG_structs.hpp"
#include "SDK/SHANKS_PUBGM_UMG_classes.hpp"

// --- 5. OYUN ANA MODÜLÜ (Basic - bizim kullandığımız) ---
#include "SDK/SHANKS_PUBGM_Basic_structs.hpp"
#include "SDK/SHANKS_PUBGM_Basic_classes.hpp"

// --- 6. SHADOW TRACKER EXTRA (PUBG ana oyun modülü) ---
// ASTExtraPlayerCharacter, ASTExtraPlayerController, ASTExtraWeapon,
// ASTExtraShootWeapon, ASTExtraVehicleBase, ASTExtraGrenadeBase,
// APickUpWrapperActor, USTExtraShootWeaponComponent vb. burada!
#include "SDK/SHANKS_PUBGM_ShadowTrackerExtra_structs.hpp"
#include "SDK/SHANKS_PUBGM_ShadowTrackerExtra_classes.hpp"

using namespace SDK;

// İmpove edilmiş ImGui DrawView sinfi
@interface ImGuiDrawView : UIViewController <MTKViewDelegate> {
    MTKView *mtkView;
}
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
+ (void)showChange:(BOOL)arg1;
+ (BOOL)isChange;
@end


// Cihazın HWID dəyərini alan funksiya
std::string getDeviceHWID() {
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    NSString *uuidString = [uuid UUIDString];
    return std::string([uuidString UTF8String]);
}

// Render serverindən Key yoxlayan funksiya
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

// Ağ-qara "DARK IOS" Su Nişanı
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
UWorld*GEWorld=0;int GWorldNum=0;TUObjectArray gobjects;UWorld*GetFullWorld(){@try{if(GWorldNum==0){gobjects=UObject::GUObjectArray->ObjObjects;for(int i=0;i<gobjects.Num();i++){@try{if(auto o=gobjects.GetByIndex(i);o&&o->IsA(UEngine::StaticClass())){auto e=(UEngine*)o;if(e&&e->GameViewport){tslFont=e->MediumFont;auto v=e->GameViewport;if(v&&v->World){GEWorld=v->World;GWorldNum=i;return v->World;}}}}@catch(...){}}}else{@try{auto e=(UEngine*)gobjects.GetByIndex(GWorldNum);if(e){if(!tslFont&&e->MediumFont)tslFont=e->MediumFont;auto v=e->GameViewport;if(v&&v->World){GEWorld=v->World;return v->World;}}}@catch(...){GWorldNum=0;return GetFullWorld();}}}@catch(...){}return 0;}
template<class T>void GetAllActorsInGame(std::vector<T*>& a){@try{auto w=GetFullWorld();if(!w)return;auto s=(UGameplayStatics*)UGameplayStatics::StaticClass();if(!s)return;TArray<AActor*> arr;s->GetAllActorsOfClass((UObject*)w,T::StaticClass(),&arr);for(int i=0;i<arr.Num();i++){@try{if(arr[i])a.push_back((T*)arr[i]);}@catch(...){}}}@catch(...){}}

float FVectorSize(const FVector& v){return sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z);}
void NormalizeAngles(FRotator& a){while(a.Pitch>180)a.Pitch-=360;while(a.Pitch<-180)a.Pitch+=360;if(a.Pitch>89)a.Pitch=89;if(a.Pitch<-89)a.Pitch=-89;while(a.Yaw>180)a.Yaw-=360;while(a.Yaw<-180)a.Yaw+=360;a.Roll=0;}
FVector GetCameraLocation(ASTExtraPlayerController* pc){@try{if(pc&&pc->PlayerCameraManager)return pc->PlayerCameraManager->CameraCache.POV.Location;}@catch(...){}return FVector();}
FRotator GetCameraRotation(ASTExtraPlayerController* pc){@try{if(pc&&pc->PlayerCameraManager)return pc->PlayerCameraManager->CameraCache.POV.Rotation;}@catch(...){}return FRotator();}

std::wstring GetItemNameFromID(int id){static std::map<int,std::wstring> m={{101001,L"akm"},{101002,L"m16a4"},{101003,L"scar-l"},{101004,L"m416"},{101005,L"groza"},{101006,L"aug"},{101007,L"g36c"},{101008,L"pp-19 bizon"},{101009,L"mp5k"},{101010,L"qbu"},{101011,L"m762"},{101012,L"mk12"},{101013,L"ump45"},{101014,L"pp-19"},{101015,L"p90"},{101016,L"mp7a2"},{102001,L"micro uzi"},{102002,L"vector"},{102003,L"thompson"},{102004,L"pp-19"},{102005,L"ump45"},{102006,L"mp5k"},{103001,L"kar98k"},{103002,L"m24"},{103003,L"awm"},{103004,L"win94"},{103005,L"mosin nagant"},{103006,L"amr"},{104001,L"s12k"},{104002,L"s686"},{104003,L"s1897"},{104004,L"dbs"},{104005,L"spas-12"},{105001,L"mini 14"},{105002,L"slr"},{105003,L"mk14 ebr"},{105004,L"vss"},{105005,L"qbu"},{105006,L"sks"},{201001,L"compensator"},{201002,L"compensator ar"},{201003,L"compensator sr"},{201004,L"flash hider"},{201005,L"flash hider ar"},{201006,L"suppressor"},{201007,L"suppressor ar"},{201008,L"suppressor sr"},{202001,L"angled grip"},{202002,L"vertical grip"},{202003,L"half grip"},{202004,L"thumb grip"},{202005,L"laser sight"},{203001,L"red dot"},{203002,L"holographic"},{203003,L"2x scope"},{203004,L"4x scope"},{203005,L"6x scope"},{203006,L"8x scope"},{203007,L"3x scope"},{301001,L"9mm"},{302001,L"7.62mm"},{303001,L"5.56mm"},{304001,L"12 gauge"},{305001,L".300 magnum"},{306001,L"40mm he"},{306002,L"40mm smoke"},{401001,L"crossbow"},{402001,L"bolt"},{403001,L"arrow"},{501001,L"backpack lv1"},{501002,L"backpack lv2"},{501003,L"backpack lv3"},{501004,L"backpack lv1"},{501005,L"backpack lv2"},{501006,L"backpack lv3"},{502001,L"helmet lv1"},{502002,L"helmet lv2"},{502003,L"helmet lv3"},{502004,L"helmet lv1"},{502005,L"helmet lv2"},{502006,L"helmet lv3"},{503001,L"vest lv1"},{503002,L"vest lv2"},{503003,L"vest lv3"},{503004,L"vest lv1"},{503005,L"vest lv2"},{503006,L"vest lv3"},{601001,L"bandage"},{601002,L"med kit"},{601003,L"first aid"},{601004,L"energy drink"},{601005,L"first aid kit"},{601006,L"painkiller"},{601007,L"painkiller"},{601008,L"adrenaline syringe"},{601009,L"syringe"},{601010,L"pills"},{602001,L"frag grenade"},{602002,L"smoke grenade"},{602003,L"molotov"},{602004,L"frag grenade"},{602005,L"stun grenade"},{602006,L"c4"},{603001,L"flare gun"},{603002,L"marker"},{604001,L"gas can"},{106001,L"metro ak"},{106002,L"metro m4"},{106003,L"metro scar"},{106004,L"metro groza"},{106005,L"metro mp5"},{106006,L"metro ump"},{206001,L"metro scope"},{206002,L"metro suppressor"},{206003,L"metro grip"},{306001,L"metro ammo"},{306002,L"metro ammo"},{406001,L"metro helmet"},{406002,L"metro vest"},{406003,L"metro backpack"},{107001,L"pan"},{107002,L"machete"},{107003,L"crowbar"},{107004,L"sickle"},{107005,L"cleaver"},{107006,L"pipe wrench"},{109001,L"sticky bomb"},{109002,L"spike trap"},{111001,L"jammer"},{111002,L"battering ram"}};auto it=m.find(id);if(it!=m.end())return it->second;if(id>=101001&&id<=199999)return L"weapon";if(id>=201001&&id<=299999)return L"attachment";if(id>=301001&&id<=399999)return L"ammo";if(id>=401001&&id<=499999)return L"throwable";if(id>=501001&&id<=599999)return L"armor";if(id>=601001&&id<=699999)return L"medical";if(id>=701001&&id<=799999)return L"key";if(id>=801001&&id<=899999)return L"upgrade";if(id>=901001&&id<=999999)return L"skin";return L"item #"+std::to_wstring(id);}

void DrawLine(AHUD* h,FVector2D a,FVector2D b,float t,FLinearColor c){@try{if(h&&h->Canvas)h->Canvas->K2_DrawLine(a,b,t,c);}@catch(...){}}
void DrawTriangleIndicatorCanvas(AHUD* h,float cx,float cy,float hgt,float wd,float angle,FLinearColor col,bool fill){@try{if(!h||!h->Canvas)return;float p1x=cx+hgt*cos(angle);float p1y=cy+hgt*sin(angle);float p2x=cx+wd*cos(angle+1.8f);float p2y=cy+wd*sin(angle+1.8f);float p3x=cx+wd*cos(angle-1.8f);float p3y=cy+wd*sin(angle-1.8f);if(fill){float minX=p1x;float maxX=p1x;float minY=p1y;float maxY=p1y;if(p2x<minX)minX=p2x;if(p3x<minX)minX=p3x;if(p2x>maxX)maxX=p2x;if(p3x>maxX)maxX=p3x;if(p2y<minY)minY=p2y;if(p3y<minY)minY=p3y;if(p2y>maxY)maxY=p2y;if(p3y>maxY)maxY=p3y;for(int px=(int)minX;px<=(int)maxX;px++){for(int py=(int)minY;py<=(int)maxY;py++){float d1=(p2x-p1x)*(py-p1y)-(p2y-p1y)*(px-p1x);float d2=(p3x-p2x)*(py-p2y)-(p3y-p2y)*(px-p2x);float d3=(p1x-p3x)*(py-p3y)-(p1y-p3y)*(px-p3x);if((d1>=0&&d2>=0&&d3>=0)||(d1<=0&&d2<=0&&d3<=0))h->Canvas->K2_DrawLine(FVector2D(px,py),FVector2D(px+1,py),1.f,col);}}}else{h->Canvas->K2_DrawLine(FVector2D(p1x,p1y),FVector2D(p2x,p2y),1.5f,col);h->Canvas->K2_DrawLine(FVector2D(p2x,p2y),FVector2D(p3x,p3y),1.5f,col);h->Canvas->K2_DrawLine(FVector2D(p3x,p3y),FVector2D(p1x,p1y),1.5f,col);}}@catch(...){}}
void DrawFOVCircle(AHUD* h,int x,int y,int r,FLinearColor c){float s=M_PI*2/32;for(float a=0;a<M_PI*2;a+=s)h->Canvas->K2_DrawLine(FVector2D(r*cos(a)+x,r*sin(a)+y),FVector2D(r*cos(a+s)+x,r*sin(a+s)+y),1.f,c);}
void DrawText(AHUD* h,FString t,FVector2D p,FLinearColor c,bool cx){@try{if(h&&h->Canvas&&tslFont)h->Canvas->K2_DrawText(tslFont,t,p,c,1.f,FLinearColor(0,0,0,0),FVector2D(0,0),cx,false,false,FLinearColor(0,0,0,0));}@catch(...){}}
void DrawSkeleton(AHUD* h,ASTExtraPlayerCharacter* pl,ASTExtraPlayerController* pc,UGameplayStatics* s,FLinearColor c){@try{if(!pl||!pl->Mesh)return;const char* n[]={"Head","neck_01","spine_03","spine_02","spine_01","pelvis","upperarm_r","lowerarm_r","hand_r","upperarm_l","lowerarm_l","hand_l","thigh_r","calf_r","foot_r","thigh_l","calf_l","foot_l"};FVector2D p[18];bool ok[18]={};for(int i=0;i<18;i++){FVector w=pl->GetBonePos(n[i],FVector(0,0,0));if(s->ProjectWorldToScreen(pc,w,false,&p[i]))ok[i]=true;}int conn[17][2]={{0,1},{1,2},{2,3},{3,4},{4,5},{1,6},{6,7},{7,8},{1,9},{9,10},{10,11},{5,12},{12,13},{13,14},{5,15},{15,16},{16,17}};for(auto& pr:conn)if(ok[pr[0]]&&ok[pr[1]])DrawLine(h,p[pr[0]],p[pr[1]],vis.line_width,c);}@catch(...){}}

ASTExtraPlayerCharacter* FindBestTarget(float fov,float maxD,int bone,bool checkVis,bool closestFirst,FRotator& outRot){@try{if(!g_LocalPlayer||!g_PlayerController)return nullptr;std::vector<ASTExtraPlayerCharacter*>p;GetAllActorsInGame(p);ASTExtraPlayerCharacter*best=nullptr;float bestVal=FLT_MAX;FVector camLoc=GetCameraLocation(g_PlayerController);FRotator camRot=GetCameraRotation(g_PlayerController);for(auto e:p){if(!e||e->GetCurrentVehicle()||e->PlayerKey==g_LocalPlayer->PlayerKey||e->TeamID==g_LocalPlayer->TeamID||e->bDead||e->bHidden)continue;if(!vis.draw_bots&&e->bEnsure)continue;float dist=e->GetDistanceTo(g_LocalPlayer)/100.f;if(dist>maxD)continue;const char* bn=bone==0?"Head":(bone==1?"neck_01":(bone==2?"spine_03":"pelvis"));FVector bp=e->GetBonePos(bn,FVector(0,0,0));if(checkVis&&!g_PlayerController->LineOfSightTo(e,bp,true))continue;FVector dir=bp-camLoc;FRotator tr=UKismetMathLibrary::Conv_VectorToRotator(dir);NormalizeAngles(tr);float da=sqrt(pow(tr.Pitch-camRot.Pitch,2)+pow(tr.Yaw-camRot.Yaw,2));if(da>fov)continue;float val=closestFirst?dist:da;if(val<bestVal){bestVal=val;best=e;outRot=tr;}}return best;}@catch(...){return nullptr;}}
float GetBulletSpeed(){@try{float bs=800;auto wm=g_LocalPlayer->WeaponManagerComponent;if(wm){auto cw=(ASTExtraShootWeapon*)wm->CurrentWeaponReplicated;if(cw&&cw->ShootWeaponEntityComp)bs=cw->ShootWeaponEntityComp->BulletFireSpeed;}return bs;}@catch(...){return 800;}}
void PredictTarget(FVector& tp,ASTExtraPlayerCharacter* t,FVector origin){@try{FVector vel=t->GetVelocity();ASTExtraVehicleBase* v=t->GetCurrentVehicle();if(v){FVector vv=v->GetVelocity();if(FVectorSize(vv)>0)vel=vv;}float bs=GetBulletSpeed();float dist=FVectorSize(tp-origin);float tt=dist/bs;tp.X+=vel.X*tt;tp.Y+=vel.Y*tt;tp.Z+=vel.Z*tt;}@catch(...){}}
bool HasWeaponEquipped(){@try{if(!g_LocalPlayer)return false;auto wm=g_LocalPlayer->WeaponManagerComponent;if(!wm)return false;int slotVal=(int)wm->GetCurrentUsingPropSlot().GetValue();return(slotVal>=1&&slotVal<=3);}@catch(...){return false;}}

void HookedShootEvent(USTExtraShootWeaponComponent* c,FVector s,FRotator r,ASTExtraShootWeapon* w,int u){@try{FRotator tr;ASTExtraPlayerCharacter* t=FindBestTarget(aim.silent_fov,aim.silent_distance,aim.silent_bone,aim.silent_vis_check,false,tr);if(!t||!aim.silent){if(orig_shoot_event)orig_shoot_event(c,s,r,w,u);return;}FVector tp=(aim.silent_bone==0)?t->GetBonePos("Head",FVector(0,0,0)):t->GetBonePos(aim.silent_bone==1?"neck_01":(aim.silent_bone==2?"spine_03":"pelvis"),FVector(0,0,0));if(aim.prediction)PredictTarget(tp,t,s);FRotator nr=UKismetMathLibrary::Conv_VectorToRotator(tp-s);NormalizeAngles(nr);if(orig_shoot_event)orig_shoot_event(c,s,nr,w,u);}@catch(...){if(orig_shoot_event)orig_shoot_event(c,s,r,w,u);}}
void HookedThrowGrenade(ASTExtraWeapon* w,FVector s,FRotator r){@try{FRotator tr;ASTExtraPlayerCharacter* t=FindBestTarget(aim.silent_fov,aim.silent_distance,aim.silent_bone,aim.silent_vis_check,false,tr);if(!t||!aim.silent){if(orig_throw_grenade)orig_throw_grenade(w,s,r);return;}FVector tp=t->K2_GetActorLocation();if(aim.prediction){FVector vel=t->GetVelocity();float tt=FVectorSize(tp-s)/15.f;tp.X+=vel.X*tt;tp.Y+=vel.Y*tt;tp.Z+=vel.Z*tt;}FVector d=tp-GetCameraLocation(g_PlayerController);d.Z+=150;FRotator nr=UKismetMathLibrary::Conv_VectorToRotator(d);NormalizeAngles(nr);if(orig_throw_grenade)orig_throw_grenade(w,s,nr);}@catch(...){if(orig_throw_grenade)orig_throw_grenade(w,s,r);}}
void HookedShootUnderbarrel(ASTExtraWeapon* w,FVector s,FRotator r){@try{FRotator tr;ASTExtraPlayerCharacter* t=FindBestTarget(aim.silent_fov,aim.silent_distance,aim.silent_bone,aim.silent_vis_check,false,tr);if(!t||!aim.silent){if(orig_shoot_underbarrel)orig_shoot_underbarrel(w,s,r);return;}FVector tp=t->K2_GetActorLocation();if(aim.prediction){FVector vel=t->GetVelocity();float tt=FVectorSize(tp-s)/75.f;tp.X+=vel.X*tt;tp.Y+=vel.Y*tt;tp.Z+=vel.Z*tt;}FVector d=tp-GetCameraLocation(g_PlayerController);d.Z+=50;FRotator nr=UKismetMathLibrary::Conv_VectorToRotator(d);NormalizeAngles(nr);if(orig_shoot_underbarrel)orig_shoot_underbarrel(w,s,nr);}@catch(...){if(orig_shoot_underbarrel)orig_shoot_underbarrel(w,s,r);}}

void SaveSettings(){NSUserDefaults* d=[NSUserDefaults standardUserDefaults];[d setBool:aim.enabled forKey:@"ae"];[d setBool:aim.silent forKey:@"as"];[d setBool:aim.show_fov forKey:@"af"];[d setBool:aim.silent_show_fov forKey:@"asf"];[d setBool:aim.prediction forKey:@"ap"];[d setBool:aim.vis_check forKey:@"av"];[d setBool:aim.silent_vis_check forKey:@"asv"];[d setBool:aim.grenade_warning forKey:@"ag"];[d setBool:aim.vehicle_aim forKey:@"ava"];[d setBool:aim.closest_priority forKey:@"acp"];[d setFloat:aim.fov_size forKey:@"afs"];[d setFloat:aim.max_distance forKey:@"am"];[d setFloat:aim.silent_distance forKey:@"asd"];[d setFloat:aim.smooth forKey:@"asm"];[d setFloat:aim.silent_smooth forKey:@"ass"];[d setFloat:aim.silent_fov forKey:@"asfo"];[d setInteger:aim.target_bone forKey:@"at"];[d setInteger:aim.trigger_mode forKey:@"atm"];[d setInteger:aim.silent_bone forKey:@"asb"];[d setBool:vis.boxes forKey:@"vb"];[d setBool:vis.health forKey:@"vh"];[d setBool:vis.skeleton forKey:@"vs"];[d setBool:vis.names forKey:@"vn"];[d setBool:vis.distance forKey:@"vd"];[d setBool:vis.snapline forKey:@"vsp"];[d setBool:vis.indicators forKey:@"vi"];[d setBool:vis.indicator_fill forKey:@"vif"];[d setFloat:vis.indicator_size forKey:@"visz"];[d setFloat:vis.indicator_width forKey:@"viw"];[d setFloat:vis.indicator_distance forKey:@"vid"];[d setBool:vis.self_skeleton forKey:@"vss"];[d setBool:vis.draw_bots forKey:@"vdb"];[d setFloat:vis.line_width forKey:@"vl"];[d setBool:itemEsp.vehicles forKey:@"iv"];[d setBool:itemEsp.metro_chests forKey:@"imc"];[d setBool:itemEsp.snow forKey:@"is"];[d setFloat:itemEsp.max_distance forKey:@"im"];[d setBool:lootEsp.enabled forKey:@"le"];[d setBool:lootEsp.weapons forKey:@"lw"];[d setBool:lootEsp.attachments forKey:@"la"];[d setBool:lootEsp.scopes forKey:@"ls"];[d setBool:lootEsp.ammo forKey:@"lam"];[d setBool:lootEsp.health forKey:@"lh"];[d setBool:lootEsp.backpacks forKey:@"lb"];[d setBool:lootEsp.helmets forKey:@"lhl"];[d setBool:lootEsp.vests forKey:@"lv"];[d setBool:lootEsp.metro_items forKey:@"lm"];[d setBool:lootEsp.rare_only forKey:@"lr"];[d setFloat:lootEsp.max_distance forKey:@"lmd"];[d synchronize];}
void LoadSettings(){NSUserDefaults* d=[NSUserDefaults standardUserDefaults];aim.enabled=[d boolForKey:@"ae"];aim.silent=[d boolForKey:@"as"];aim.show_fov=[d boolForKey:@"af"];aim.silent_show_fov=[d boolForKey:@"asf"];aim.prediction=[d boolForKey:@"ap"];aim.vis_check=[d boolForKey:@"av"];aim.silent_vis_check=[d boolForKey:@"asv"];aim.grenade_warning=[d boolForKey:@"ag"];aim.vehicle_aim=[d boolForKey:@"ava"];aim.closest_priority=[d boolForKey:@"acp"];aim.fov_size=[d floatForKey:@"afs"];aim.max_distance=[d floatForKey:@"am"];aim.silent_distance=[d floatForKey:@"asd"];aim.smooth=[d floatForKey:@"asm"];aim.silent_smooth=[d floatForKey:@"ass"];aim.silent_fov=[d floatForKey:@"asfo"];aim.target_bone=(int)[d integerForKey:@"at"];aim.trigger_mode=(int)[d integerForKey:@"atm"];aim.silent_bone=(int)[d integerForKey:@"asb"];vis.boxes=[d boolForKey:@"vb"];vis.health=[d boolForKey:@"vh"];vis.skeleton=[d boolForKey:@"vs"];vis.names=[d boolForKey:@"vn"];vis.distance=[d boolForKey:@"vd"];vis.snapline=[d boolForKey:@"vsp"];vis.indicators=[d boolForKey:@"vi"];vis.indicator_fill=[d boolForKey:@"vif"];vis.indicator_size=[d floatForKey:@"visz"];vis.indicator_width=[d floatForKey:@"viw"];vis.indicator_distance=[d floatForKey:@"vid"];vis.self_skeleton=[d boolForKey:@"vss"];vis.draw_bots=[d boolForKey:@"vdb"];vis.line_width=[d floatForKey:@"vl"];itemEsp.vehicles=[d boolForKey:@"iv"];itemEsp.metro_chests=[d boolForKey:@"imc"];itemEsp.snow=[d boolForKey:@"is"];itemEsp.max_distance=[d floatForKey:@"im"];lootEsp.enabled=[d boolForKey:@"le"];lootEsp.weapons=[d boolForKey:@"lw"];lootEsp.attachments=[d boolForKey:@"la"];lootEsp.scopes=[d boolForKey:@"ls"];lootEsp.ammo=[d boolForKey:@"lam"];lootEsp.health=[d boolForKey:@"lh"];lootEsp.backpacks=[d boolForKey:@"lb"];lootEsp.helmets=[d boolForKey:@"lhl"];lootEsp.vests=[d boolForKey:@"lv"];lootEsp.metro_items=[d boolForKey:@"lm"];lootEsp.rare_only=[d boolForKey:@"lr"];lootEsp.max_distance=[d floatForKey:@"lmd"];if(aim.fov_size==0)aim.fov_size=120;if(aim.max_distance==0)aim.max_distance=300;if(aim.silent_distance==0)aim.silent_distance=300;if(aim.smooth==0)aim.smooth=2.5f;if(aim.silent_fov==0)aim.silent_fov=90;if(aim.silent_smooth==0)aim.silent_smooth=1.0f;if(vis.indicator_size==0)vis.indicator_size=20;if(vis.indicator_width==0)vis.indicator_width=50;if(vis.indicator_distance==0)vis.indicator_distance=180;if(vis.line_width==0)vis.line_width=1.5f;if(itemEsp.max_distance==0)itemEsp.max_distance=200;if(lootEsp.max_distance==0)lootEsp.max_distance=150;}

void RenderESP(AHUD* hud,int w,int h){@try{if(!tslFont){GetFullWorld();if(!tslFont)return;}auto s=(UGameplayStatics*)UGameplayStatics::StaticClass();auto world=GetFullWorld();ASTExtraPlayerController* pc=nullptr;if(world&&world->NetDriver&&world->NetDriver->ServerConnection)pc=(ASTExtraPlayerController*)world->NetDriver->ServerConnection->PlayerController;if(!pc)return;std::vector<ASTExtraPlayerCharacter*>pl;GetAllActorsInGame(pl);ASTExtraPlayerCharacter*lp=nullptr;for(auto p:pl)if(p&&p->PlayerKey==pc->PlayerKey){lp=p;break;}if(!lp)return;g_LocalPlayer=lp;g_PlayerController=pc;bool hasWeapon=HasWeaponEquipped();auto wm=lp->WeaponManagerComponent;if(wm&&aim.silent){auto slot=wm
