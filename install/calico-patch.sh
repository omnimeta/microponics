#!/bin/sh

cat <<EOF
spec:
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: calico-node
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      creationTimestamp: null
      labels:
        k8s-app: calico-node
    spec:
      containers:
      - env:
        - name: DATASTORE_TYPE
          value: kubernetes
        - name: WAIT_FOR_DATASTORE
          value: "true"
        - name: NODENAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: spec.nodeName
        - name: CALICO_NETWORKING_BACKEND
          valueFrom:
            configMapKeyRef:
              key: calico_backend
              name: calico-config
        - name: CLUSTER_TYPE
          value: k8s,bgp
        - name: IP
          value: "`ip route get 1.2.3.4 | awk '{ print $7 }' | head -n 1`"
        - name: IP_AUTODETECTION_METHOD
          value: first-found
        - name: CALICO_IPV4POOL_VXLAN
          value: Always
        - name: FELIX_IPINIPMTU
          valueFrom:
            configMapKeyRef:
              key: veth_mtu
              name: calico-config
        - name: CALICO_IPV4POOL_CIDR
          value: 10.1.0.0/16
        - name: CALICO_DISABLE_FILE_LOGGING
          value: "true"
        - name: FELIX_DEFAULTENDPOINTTOHOSTACTION
          value: ACCEPT
        - name: FELIX_IPV6SUPPORT
          value: "false"
        - name: FELIX_LOGSEVERITYSCREEN
          value: error
        - name: FELIX_HEALTHENABLED
          value: "true"
        image: calico/node:v3.13.2
        imagePullPolicy: IfNotPresent
        livenessProbe:
          exec:
            command:
            - /bin/calico-node
            - -felix-live
          failureThreshold: 6
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        name: calico-node
        readinessProbe:
          exec:
            command:
            - /bin/calico-node
            - -felix-ready
          failureThreshold: 3
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources:
          requests:
            cpu: 250m
        securityContext:
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /lib/modules
          name: lib-modules
          readOnly: true
        - mountPath: /run/xtables.lock
          name: xtables-lock
        - mountPath: /var/run/calico
          name: var-run-calico
        - mountPath: /var/lib/calico
          name: var-lib-calico
        - mountPath: /var/run/nodeagent
          name: policysync
      dnsPolicy: ClusterFirst
      hostNetwork: true
      initContainers:
      - command:
        - /opt/cni/bin/calico-ipam
        - -upgrade
        env:
        - name: KUBERNETES_NODE_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: spec.nodeName
        - name: CALICO_NETWORKING_BACKEND
          valueFrom:
            configMapKeyRef:
              key: calico_backend
              name: calico-config
        image: calico/cni:v3.13.2
        imagePullPolicy: IfNotPresent
        name: upgrade-ipam
        resources: {}
        securityContext:
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/lib/cni/networks
          name: host-local-net-dir
        - mountPath: /host/opt/cni/bin
          name: cni-bin-dir
      - command:
        - /install-cni.sh
        env:
        - name: CNI_CONF_NAME
          value: 10-calico.conflist
        - name: CNI_NETWORK_CONFIG
          valueFrom:
            configMapKeyRef:
              key: cni_network_config
              name: calico-config
        - name: KUBERNETES_NODE_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: spec.nodeName
        - name: CNI_MTU
          valueFrom:
            configMapKeyRef:
              key: veth_mtu
              name: calico-config
        - name: SLEEP
          value: "false"
        - name: CNI_NET_DIR
          value: /var/snap/microk8s/current/args/cni-network
        image: calico/cni:v3.13.2
        imagePullPolicy: IfNotPresent
        name: install-cni
        resources: {}
        securityContext:
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /host/opt/cni/bin
          name: cni-bin-dir
        - mountPath: /host/etc/cni/net.d
          name: cni-net-dir
      - image: calico/pod2daemon-flexvol:v3.13.2
        imagePullPolicy: IfNotPresent
        name: flexvol-driver
        resources: {}
        securityContext:
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /host/driver
          name: flexvol-driver-host
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-node-critical
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: calico-node
      serviceAccountName: calico-node
      terminationGracePeriodSeconds: 0
      tolerations:
      - effect: NoSchedule
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoExecute
        operator: Exists
      volumes:
      - hostPath:
          path: /lib/modules
          type: ""
        name: lib-modules
      - hostPath:
          path: /var/snap/microk8s/current/var/run/calico
          type: ""
        name: var-run-calico
      - hostPath:
          path: /var/snap/microk8s/current/var/lib/calico
          type: ""
        name: var-lib-calico
      - hostPath:
          path: /run/xtables.lock
          type: FileOrCreate
        name: xtables-lock
      - hostPath:
          path: /var/snap/microk8s/current/opt/cni/bin
          type: ""
        name: cni-bin-dir
      - hostPath:
          path: /var/snap/microk8s/current/args/cni-network
          type: ""
        name: cni-net-dir
      - hostPath:
          path: /var/snap/microk8s/current/var/lib/cni/networks
          type: ""
        name: host-local-net-dir
      - hostPath:
          path: /var/snap/microk8s/current/var/run/nodeagent
          type: DirectoryOrCreate
        name: policysync
      - hostPath:
          path: /usr/libexec/kubernetes/kubelet-plugins/volume/exec/nodeagent~uds
          type: DirectoryOrCreate
        name: flexvol-driver-host
EOF
