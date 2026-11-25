import os

directories = [
    "auth-service",
    "user-service",
    "account-service",
    "transfer-service",
    "payroll-service",
    "transaction-service",
    "notification-service",
]

to_remove = """		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<optional>true</optional>
		</dependency>
	</dependencies>
	</dependencyManagement>"""

replacement = """	</dependencies>
	</dependencyManagement>"""

for d in directories:
    filepath = os.path.join(d, "pom.xml")
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            content = f.read()
            
        content = content.replace(to_remove, replacement)
            
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed {filepath}")
