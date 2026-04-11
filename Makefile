.PHONY: help p1-up p1-down p2-up p2-down p3-setup p3-clean bonus-up bonus-down verify-all cleanup

CURRENT_DIR := $(shell pwd)

help:
	@echo "Inception-of-Things (IoT) - Makefile Commands"
	@echo ""
	@echo "Part 1 (K3s 2-Node Cluster):"
	@echo "  make p1-up          Start Part 1 VMs"
	@echo "  make p1-down        Stop Part 1 VMs"
	@echo "  make p1-status      Show Part 1 status"
	@echo ""
	@echo "Part 2 (K3s with Applications):"
	@echo "  make p2-up          Start Part 2 VM"
	@echo "  make p2-down        Stop Part 2 VM"
	@echo "  make p2-status      Show Part 2 status"
	@echo ""
	@echo "Part 3 (K3d + Argo CD):"
	@echo "  make p3-setup       Setup K3d and Argo CD"
	@echo "  make p3-clean       Cleanup K3d cluster"
	@echo "  make p3-verify      Verify Part 3 setup"
	@echo ""
	@echo "Bonus (GitLab Integration):"
	@echo "  make bonus-up       Start Bonus VM"
	@echo "  make bonus-down     Stop Bonus VM"
	@echo "  make bonus-verify   Verify Bonus setup"
	@echo ""
	@echo "All:"
	@echo "  make cleanup        Clean everything"
	@echo "  make verify-all     Verify all parts"

p1-up:
	cd p1 && vagrant up

p1-down:
	cd p1 && vagrant halt

p1-status:
	cd p1 && vagrant status

p2-up:
	cd p2 && vagrant up

p2-down:
	cd p2 && vagrant halt

p2-status:
	cd p2 && vagrant status

p3-setup:
	bash p3/scripts/setup_k3d.sh
	bash p3/scripts/setup_argocd.sh
	@echo "P3 setup complete. Run 'kubectl apply -f p3/confs/argocd-app.yaml' to deploy"

p3-clean:
	k3d cluster delete khbouy || true

p3-verify:
	bash p3/scripts/verify_setup.sh

bonus-up:
	cd bonus && vagrant up

bonus-down:
	cd bonus && vagrant halt

bonus-verify:
	bash bonus/scripts/verify_bonus_setup.sh

cleanup:
	@echo "Cleaning up Part 1..."
	cd p1 && vagrant destroy -f || true
	@echo "Cleaning up Part 2..."
	cd p2 && vagrant destroy -f || true
	@echo "Cleaning up Part 3..."
	k3d cluster delete khbouy || true
	@echo "Cleaning up Bonus..."
	cd bonus && vagrant destroy -f || true
	k3d cluster delete khbouy-gitlab || true
	@echo "Cleanup complete"

verify-all:
	@echo "Verifying Part 1..."
	cd p1 && vagrant status || echo "Part 1 not running"
	@echo "Verifying Part 2..."
	cd p2 && vagrant status || echo "Part 2 not running"
	@echo "Verifying Part 3..."
	bash p3/scripts/verify_setup.sh || true
	@echo "Verifying Bonus..."
	bash bonus/scripts/verify_bonus_setup.sh || true

p1-ssh:
	cd p1 && vagrant ssh khbouyS

p1-ssh-worker:
	cd p1 && vagrant ssh khbouyW

p2-ssh:
	cd p2 && vagrant ssh khbouyS

p3-kubeconfig:
	@echo "export KUBECONFIG=$$(k3d kubeconfig get khbouy)"

bonus-kubeconfig:
	@echo "export KUBECONFIG=$$(k3d kubeconfig get khbouy-gitlab)"

bonus-gitlab-password:
	bash bonus/scripts/get_gitlab_password.sh

bonus-argocd-password:
	bash bonus/scripts/get_argocd_password.sh
