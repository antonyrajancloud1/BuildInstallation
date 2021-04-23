import cgitb
cgitb.enable()

print("Content-Type: text/plain;charset=utf-8")
print()

print("Hello World!")

template = "<html><body><h1>Hello {who}!</h1></body></html>"
print(template.format(who="Reader"))