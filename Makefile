KIND_VERSION = 0.20.0
KUBERNETES_VERSION = 1.26.6
KUSTOMIZE_VERSION = 5.1.0

KIND := $(shell pwd)/bin/kind
KUBECTL := $(shell pwd)/bin/kubectl
KUSTOMIZE := $(shell pwd)/bin/kustomize
ARGOCD := $(shell pwd)/bin/argocd

ARGOCD_VERSION = 2.8.3
ARGOCD_IMAGE_UPDATER_VERSION = 0.12.2
CERT_MANAGER_VERSION = 1.11.4

.PHONY: get-argocd-password
get-argocd-password:
	@$(KUBECTL) -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

.PHONY: setup
setup: $(KUBECTL) $(KUSTOMIZE) $(ARGOCD)
	@echo "setup argocd"
	-@$(KUBECTL) create namespace argocd
	$(KUSTOMIZE) build argocd/base/ | $(KUBECTL) apply -n argocd -f -
	$(KUBECTL) wait -n argocd deploy --all --for condition=available --timeout 3m
	sleep 10
	$(ARGOCD) login localhost:30080 --insecure --username admin --password $(shell make get-argocd-password)
	$(ARGOCD) app create argocd-config --upsert --repo https://github.com/kmdkuk/argocd-test.git --path argocd-config/base \
				--dest-namespace argocd --dest-server https://kubernetes.default.svc --sync-policy none --revision main

.PHONY: start
start: $(KIND)
	$(KIND) create cluster --name=kmdkuk --config cluster-config.yaml --image kindest/node:v${KUBERNETES_VERSION}

.PHONY: stop
stop: $(KIND)
	$(KIND) delete cluster --name=kmdkuk

.PHONY: clean
clean:
	rm -rf bin

.PHONY: update-argocd
update-argocd:
	curl -sfL -o argocd/base/upstream/install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/v${ARGOCD_VERSION}/manifests/ha/install.yaml

update-argocd-image-updater:
	curl -sfL -o argocd-image-updater/base/upstream/install.yaml https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/v${ARGOCD_IMAGE_UPDATER_VERSION}/manifests/install.yaml

.PHONY: update-cert-manager
update-cert-manager:
	curl -sLf -o cert-manager/base/upstream/cert-manager.yaml \
		https://github.com/jetstack/cert-manager/releases/download/v${CERT_MANAGER_VERSION}/cert-manager.yaml

$(KIND):
	mkdir -p bin
	curl -sfL -o $@ https://github.com/kubernetes-sigs/kind/releases/download/v$(KIND_VERSION)/kind-linux-amd64
	chmod a+x $@

$(KUBECTL):
	mkdir -p bin
	curl -sfL -o $@ https://dl.k8s.io/release/v$(KUBERNETES_VERSION)/bin/linux/amd64/kubectl
	chmod a+x $@

$(KUSTOMIZE):
	mkdir -p bin
	wget -O bin/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v$(KUSTOMIZE_VERSION)_linux_amd64.tar.gz
	tar zxf bin/kustomize.tar.gz -C bin
	rm bin/kustomize.tar.gz

$(ARGOCD):
	mkdir -p bin
	curl -sfL -o $@ https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64
	chmod a+x $@
