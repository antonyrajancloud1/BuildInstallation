import subprocess

process = subprocess.check_output("ls ~/builds", shell=True);
process = str(process)
RunningBuilds = process.split('\\n')
print(RunningBuilds)



