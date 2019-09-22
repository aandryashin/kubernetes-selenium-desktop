#!/bin/bash

multipass launch --name moon --c 4 --m 4G 18.04

multipass exec moon -- sudo snap install microk8s --classic

until multipass exec moon -- sudo microk8s.status
do
	sleep 1
done
echo

multipass exec moon -- sudo microk8s.enable dns

multipass exec moon -- cat << EOF | multipass exec moon -- sudo microk8s.kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: moon
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  namespace: moon
  name: moon
rules:
- apiGroups:
  - "*"
  resources:
  - "*"
  verbs:
  - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: moon
  namespace: moon
roleRef:
  kind: Role
  name: moon
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  namespace: moon
  name: default
---
kind: Service
apiVersion: v1
metadata:
  name: moon
  namespace: moon
spec:
  selector:
    app: moon
  ports:
  - name: "moon"
    protocol: TCP
    port: 4444
  - name: "moon-ui"
    protocol: TCP
    port: 8080
  type: LoadBalancer
  externalIPs: ["$(multipass info moon | grep IPv4 | awk '{print $2}')"]
#---
#apiVersion: extensions/v1beta1
#kind: Ingress
#metadata:
#  annotations:
#    kubernetes.io/ingress.class: nginx
#  name: moon
#  namespace: moon
#spec:
#  rules:
#    - host: moon.example.com # Replace with correct cluster FQDN
#      http:
#        paths:
#          - path: /wd/hub
#            backend:
#              serviceName: moon
#              servicePort: 4444
#          - path: /
#            backend:
#              serviceName: moon
#              servicePort: 8080
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: moon
  namespace: moon
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: moon
    spec:
      containers:
      - name: moon
        image: aerokube/moon:1.3.8
        args: ["-namespace", "moon", "-license-file", "/license/license.key", "-disable-cpu-limits", "-disable-memory-limits"]
        ports:
        - containerPort: 4444
        volumeMounts:
        - name: quota
          mountPath: /quota
          readOnly: true
#        - name: config
#          mountPath: /config
#          readOnly: true
#        - name: credentials
#          mountPath: /credentials
#          readOnly: true
        - name: users
          mountPath: /users
          readOnly: true
        - name: license-key
          mountPath: /license
          readOnly: true
      - name: moon-api
        image: aerokube/moon-api:1.3.8
        args: ["-namespace", "moon", "-license-file", "/license/license.key", "-listen", ":8888"]
        ports:
        - containerPort: 8888
        volumeMounts:
        - name: quota
          mountPath: /quota
          readOnly: true
        - name: license-key
          mountPath: /license
          readOnly: true
      - name: selenoid-ui
        image: aerokube/selenoid-ui:1.8.1
        args: ["-status-uri", "http://localhost:8888", "-webdriver-uri", "http://localhost:4444"]
        ports:
        - name: selenoid-ui
          containerPort: 8080
      volumes:
      - name: quota
        configMap:
          name: quota
#      - name: config
#        configMap:
#          name: config
#      - name: credentials
#        secret:
#          secretName: credentials
      - name: users
        secret:
          secretName: users
      - name: license-key
        secret:
          secretName: licensekey
#---
#apiVersion: v1
#kind: ConfigMap
#metadata:
#  name: config
#  namespace: moon
#data:
#  service.json: |
#    {
#      "s3": {
#        "endpoint": "https://storage.googleapis.com",
#        "bucketName": "moon-test",
#        "version": "S3v2"
#      }
#    }
#---
#apiVersion: v1
#kind: Secret
#metadata:
#  name: credentials
#  namespace: moon
#stringData:
#  s3.accessKey: "access-key-value"
#  s3.secretKey: "secret-key-value"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: quota
  namespace: moon
data:
  browsers.json: |
    {
      "firefox": {
        "default": "69.0",
        "versions": {
          "69.0": {
            "image": "selenoid/vnc_firefox:69.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "68.0": {
            "image": "selenoid/vnc_firefox:68.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "67.0": {
            "image": "selenoid/vnc_firefox:67.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "66.0": {
            "image": "selenoid/vnc_firefox:66.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "65.0": {
            "image": "selenoid/vnc_firefox:65.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "64.0": {
            "image": "selenoid/vnc_firefox:64.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "63.0": {
            "image": "selenoid/vnc_firefox:63.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "62.0": {
            "image": "selenoid/vnc_firefox:62.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "61.0": {
            "image": "selenoid/vnc_firefox:61.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "60.0": {
            "image": "selenoid/vnc_firefox:60.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "59.0": {
            "image": "selenoid/vnc_firefox:59.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "58.0": {
            "image": "selenoid/vnc_firefox:58.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "57.0": {
            "image": "selenoid/vnc_firefox:57.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "56.0": {
            "image": "selenoid/vnc_firefox:56.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "55.0": {
            "image": "selenoid/vnc_firefox:55.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "54.0": {
            "image": "selenoid/vnc_firefox:54.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "53.0": {
            "image": "selenoid/vnc_firefox:53.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "52.0": {
            "image": "selenoid/vnc_firefox:52.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "51.0": {
            "image": "selenoid/vnc_firefox:51.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "50.0": {
            "image": "selenoid/vnc_firefox:50.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "49.0": {
            "image": "selenoid/vnc_firefox:49.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "48.0": {
            "image": "selenoid/vnc_firefox:48.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "47.0": {
            "image": "selenoid/vnc_firefox:47.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "46.0": {
            "image": "selenoid/vnc_firefox:46.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "45.0": {
            "image": "selenoid/vnc_firefox:45.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "44.0": {
            "image": "selenoid/vnc_firefox:44.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "43.0": {
            "image": "selenoid/vnc_firefox:43.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "42.0": {
            "image": "selenoid/vnc_firefox:42.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "41.0": {
            "image": "selenoid/vnc_firefox:41.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "40.0": {
            "image": "selenoid/vnc_firefox:40.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "39.0": {
            "image": "selenoid/vnc_firefox:39.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "38.0": {
            "image": "selenoid/vnc_firefox:38.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "37.0": {
            "image": "selenoid/vnc_firefox:37.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "36.0": {
            "image": "selenoid/vnc_firefox:36.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "35.0": {
            "image": "selenoid/vnc_firefox:35.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "34.0": {
            "image": "selenoid/vnc_firefox:34.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "33.0": {
            "image": "selenoid/vnc_firefox:33.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "32.0": {
            "image": "selenoid/vnc_firefox:32.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "31.0": {
            "image": "selenoid/vnc_firefox:31.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "30.0": {
            "image": "selenoid/vnc_firefox:30.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "29.0": {
            "image": "selenoid/vnc_firefox:29.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "28.0": {
            "image": "selenoid/vnc_firefox:28.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "27.0": {
            "image": "selenoid/vnc_firefox:27.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "26.0": {
            "image": "selenoid/vnc_firefox:26.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "25.0": {
            "image": "selenoid/vnc_firefox:25.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "24.0": {
            "image": "selenoid/vnc_firefox:24.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "23.0": {
            "image": "selenoid/vnc_firefox:23.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "22.0": {
            "image": "selenoid/vnc_firefox:22.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "21.0": {
            "image": "selenoid/vnc_firefox:21.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "20.0": {
            "image": "selenoid/vnc_firefox:20.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "19.0": {
            "image": "selenoid/vnc_firefox:19.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "18.0": {
            "image": "selenoid/vnc_firefox:18.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "17.0": {
            "image": "selenoid/vnc_firefox:17.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "16.0": {
            "image": "selenoid/vnc_firefox:16.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "15.0": {
            "image": "selenoid/vnc_firefox:15.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "14.0": {
            "image": "selenoid/vnc_firefox:14.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "13.0": {
            "image": "selenoid/vnc_firefox:13.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "12.0": {
            "image": "selenoid/vnc_firefox:12.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "11.0": {
            "image": "selenoid/vnc_firefox:11.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "10.0": {
            "image": "selenoid/vnc_firefox:10.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "9.0": {
            "image": "selenoid/vnc_firefox:9.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "8.0": {
            "image": "selenoid/vnc_firefox:8.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "7.0": {
            "image": "selenoid/vnc_firefox:7.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "6.0": {
            "image": "selenoid/vnc_firefox:6.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "5.0": {
            "image": "selenoid/vnc_firefox:5.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "4.0": {
            "image": "selenoid/vnc_firefox:4.0",
            "port": "4444",
            "path": "/wd/hub"
          },
          "3.6": {
            "image": "selenoid/vnc_firefox:3.6",
            "port": "4444",
            "path": "/wd/hub"
          }
        }
      },
      "chrome": {
        "default": "77.0",
        "versions": {
          "77.0": {
            "image": "selenoid/vnc_chrome:77.0",
            "port": "4444"
          },
          "76.0": {
            "image": "selenoid/vnc_chrome:76.0",
            "port": "4444"
          },
          "75.0": {
            "image": "selenoid/vnc_chrome:75.0",
            "port": "4444"
          },
          "74.0": {
            "image": "selenoid/vnc_chrome:74.0",
            "port": "4444"
          },
          "73.0": {
            "image": "selenoid/vnc_chrome:73.0",
            "port": "4444"
          },
          "72.0": {
            "image": "selenoid/vnc_chrome:72.0",
            "port": "4444"
          },
          "71.0": {
            "image": "selenoid/vnc_chrome:71.0",
            "port": "4444"
          },
          "70.0": {
            "image": "selenoid/vnc_chrome:70.0",
            "port": "4444"
          },
          "69.0": {
            "image": "selenoid/vnc_chrome:69.0",
            "port": "4444"
          },
          "68.0": {
            "image": "selenoid/vnc_chrome:68.0",
            "port": "4444"
          },
          "67.0": {
            "image": "selenoid/vnc_chrome:67.0",
            "port": "4444"
          },
          "66.0": {
            "image": "selenoid/vnc_chrome:66.0",
            "port": "4444"
          },
          "65.0": {
            "image": "selenoid/vnc_chrome:65.0",
            "port": "4444"
          },
          "64.0": {
            "image": "selenoid/vnc_chrome:64.0",
            "port": "4444"
          },
          "63.0": {
            "image": "selenoid/vnc_chrome:63.0",
            "port": "4444"
          },
          "62.0": {
            "image": "selenoid/vnc_chrome:62.0",
            "port": "4444"
          },
          "61.0": {
            "image": "selenoid/vnc_chrome:61.0",
            "port": "4444"
          },
          "60.0": {
            "image": "selenoid/vnc_chrome:60.0",
            "port": "4444"
          },
          "59.0": {
            "image": "selenoid/vnc_chrome:59.0",
            "port": "4444"
          },
          "58.0": {
            "image": "selenoid/vnc_chrome:58.0",
            "port": "4444"
          },
          "57.0": {
            "image": "selenoid/vnc_chrome:57.0",
            "port": "4444"
          },
          "56.0": {
            "image": "selenoid/vnc_chrome:56.0",
            "port": "4444"
          },
          "55.0": {
            "image": "selenoid/vnc_chrome:55.0",
            "port": "4444"
          },
          "54.0": {
            "image": "selenoid/vnc_chrome:54.0",
            "port": "4444"
          },
          "53.0": {
            "image": "selenoid/vnc_chrome:53.0",
            "port": "4444"
          },
          "52.0": {
            "image": "selenoid/vnc_chrome:52.0",
            "port": "4444"
          },
          "51.0": {
            "image": "selenoid/vnc_chrome:51.0",
            "port": "4444"
          },
          "50.0": {
            "image": "selenoid/vnc_chrome:50.0",
            "port": "4444"
          },
          "49.0": {
            "image": "selenoid/vnc_chrome:49.0",
            "port": "4444"
          },
          "48.0": {
            "image": "selenoid/vnc_chrome:48.0",
            "port": "4444"
          }
        }
      },
      "opera": {
        "default": "60.0",
        "versions": {
          "62.0": {
            "image": "selenoid/vnc_opera:62.0",
            "port": "4444"
          },
          "60.0": {
            "image": "selenoid/vnc_opera:60.0",
            "port": "4444"
          },
          "58.0": {
            "image": "selenoid/vnc_opera:58.0",
            "port": "4444"
          },
          "57.0": {
            "image": "selenoid/vnc_opera:57.0",
            "port": "4444"
          },
          "56.0": {
            "image": "selenoid/vnc_opera:56.0",
            "port": "4444"
          },
          "55.0": {
            "image": "selenoid/vnc_opera:55.0",
            "port": "4444"
          },
          "54.0": {
            "image": "selenoid/vnc_opera:54.0",
            "port": "4444"
          },
          "53.0": {
            "image": "selenoid/vnc_opera:53.0",
            "port": "4444"
          },
          "52.0": {
            "image": "selenoid/vnc_opera:52.0",
            "port": "4444"
          },
          "51.0": {
            "image": "selenoid/vnc_opera:51.0",
            "port": "4444"
          },
          "50.0": {
            "image": "selenoid/vnc_opera:50.0",
            "port": "4444"
          },
          "49.0": {
            "image": "selenoid/vnc_opera:49.0",
            "port": "4444"
          },
          "48.0": {
            "image": "selenoid/vnc_opera:48.0",
            "port": "4444"
          },
          "47.0": {
            "image": "selenoid/vnc_opera:47.0",
            "port": "4444"
          },
          "46.0": {
            "image": "selenoid/vnc_opera:46.0",
            "port": "4444"
          },
          "45.0": {
            "image": "selenoid/vnc_opera:45.0",
            "port": "4444"
          },
          "44.0": {
            "image": "selenoid/vnc_opera:44.0",
            "port": "4444"
          },
          "43.0": {
            "image": "selenoid/vnc_opera:43.0",
            "port": "4444"
          },
          "42.0": {
            "image": "selenoid/vnc_opera:42.0",
            "port": "4444"
          },
          "41.0": {
            "image": "selenoid/vnc_opera:41.0",
            "port": "4444"
          },
          "40.0": {
            "image": "selenoid/vnc_opera:40.0",
            "port": "4444"
          },
          "39.0": {
            "image": "selenoid/vnc_opera:39.0",
            "port": "4444"
          },
          "38.0": {
            "image": "selenoid/vnc_opera:38.0",
            "port": "4444"
          },
          "37.0": {
            "image": "selenoid/vnc_opera:37.0",
            "port": "4444"
          },
          "36.0": {
            "image": "selenoid/vnc_opera:36.0",
            "port": "4444"
          },
          "35.0": {
            "image": "selenoid/vnc_opera:35.0",
            "port": "4444"
          },
          "34.0": {
            "image": "selenoid/vnc_opera:34.0",
            "port": "4444"
          },
          "33.0": {
            "image": "selenoid/vnc_opera:33.0",
            "port": "4444"
          },
          "12.16": {
            "image": "selenoid/vnc:opera_12.16",
            "port": "4444",
            "path": "/wd/hub"
          }
        }
      }
    }
---
apiVersion: v1
kind: Secret
metadata:
  name: users
  namespace: moon
stringData:
  users.htpasswd: ""
---
apiVersion: v1
kind: Secret
metadata:
  name: licensekey
  namespace: moon
stringData:
  license.key: MG1RSVdpc2Z6YjdQQVZjd2lpei9KMkd1T3dzMTFuL1dlRjVSc3NOMUcxZk9QaUxWa3Q5SnBIakIxa09wWm0vVFJqQ0tsa21xVG1OODVRZnlQbjBjVmRHVWFLampTOFF1a3VLRXRPcEUwbnEySG16QWFQWHRDYTVjMm9jZzZFaUJqeFd5ODE4UFBHZzNCNWpCYXlha3oweFBscFl1RnB0V0U1Q3FwOGl5VDdKTk9abG5aSmlPdnRmZDFvSG1nNnVwVXBLV2E4RmYwWHcreERIR29ZTE1XTldPb1hvT2ZCUnZpcDhPWW05a1FqN0hBWWVOYUtLT1lPWlVJa1dsb1gxdjNOT1htTFpZalhsQ3h1Q3V6NWhiQjIwSjVIY0JTYnZybm9zYm14RXFkSFpQWVBKWUlKTzZvVlBnODhQeFErZ1EyTk5sWG82TC9XeXU3aisrNU0rSEdPcXlOSEdlNGx4Zm1nNVhjMWlnNkN1OCtNSVVYRzNqUllqOUY4ZHdReWpSbFNMNmFpL2dRQnc3TzY0U0lwdVF2d29jYi9kVzFSYWFRVkd3ZXYrOVdING8zRWRrYkVONUhRTmQ2MUxsUnFNdmtKeWVHV21tVlVUZ2dsMDRsTFFLTmZNVG81L2JVakNBMGhNeER5VHNJdmVRRGFMMklvTWpvcFk4VERlK1U2bUJvUDVxNVYrcCtDQVhjbjYxQlRaUVp0bmNqL0JBVkdNOEZ4NW9rWHRYSVAxUkY0a1VCckZVTDFyTWF1VkZqSk5xU1pLT293dUpMTTg2SEZ0Sld0eUlRK3ZZZm1pZU0xM292MnVleDBoRlhRdFkvMkt1dUhhN3dKV2pFT0pqaEVzTjhXSy82ZlFFbi9EQzcrNkw3NzhlbmVVZ2lLZ3VFbjlMMXZMYVZ5VWtQaWc9O2V5SnNhV05sYm5ObFpTSTZJa1JsWm1GMWJIUWlMQ0p3Y205a2RXTjBJam9pVFc5dmJpSXNJbTFoZUZObGMzTnBiMjV6SWpvMGZRPT0=
EOF
