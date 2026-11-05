# install_icons.py: puts icons6/out/<key> into every star app in /Applications (re-signed "Mantra Apps") and into each
# app's own repository (icon/six_1024.png or the .icns its build copies), from repos.json. python3 install_icons.py
import json,os,subprocess,plistlib,shutil,glob
H=os.path.dirname(os.path.abspath(__file__)); D=os.path.expanduser('~/Developer'); O=H+'/out'
rows={r['key']:r for r in json.load(open(os.path.expanduser('~/.config/star-rows.json')))['rows']}
icons=json.load(open(H+'/icons.json'))['icons']; m=json.load(open(H+'/repos.json'))
special={'e16resolve':'icon/e16resolve.icns','claudevoice':'icon/subtitle.icns','answerclaude':'icon/answer.icns'}
bad=[]
# Marko 5.11.2026: "bring back old icons": these keep their own old icon, never the six letters
keep_old={'g815','emmonitor'}
for k,*_ in icons:
    if k in keep_old: continue
    app=os.path.expanduser(rows[k]['app']); info=plistlib.load(open(app+'/Contents/Info.plist','rb'))
    f=info.get('CFBundleIconFile') or 'AppIcon'; f+= '' if f.endswith('.icns') else '.icns'
    shutil.copy(f'{O}/{k}/AppIcon.icns',app+'/Contents/Resources/'+f)
    r=subprocess.run(['codesign','--force','--preserve-metadata=entitlements,identifier,requirements','-s','Mantra Apps',app],capture_output=True,text=True)
    if r.returncode: bad.append(k)
    os.utime(app); subprocess.run(['/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister','-f',app])
    bd=os.path.dirname(D+'/'+m[k])
    if k in special: shutil.copy(f'{O}/{k}/AppIcon.icns',bd+'/'+special[k]); continue
    six={'oxi':[bd+'/icon/six_1024.png'],'appledoor':[bd+'/icon/six_1024.png'],'freedom':[bd+'/freedom/six_1024.png']}.get(k) \
        or [p for p in glob.glob(bd+'/**/six_1024.png',recursive=True) if '/build/' not in p]
    for p in six: shutil.copy(f'{O}/{k}/icon_1024.png',p)
    if os.path.exists(bd+'/icon/AppIcon.icns'): shutil.copy(f'{O}/{k}/AppIcon.icns',bd+'/icon/AppIcon.icns')
print('installed',len(icons),'not signed:',bad)
