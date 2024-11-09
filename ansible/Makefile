default: deploy

deploy: 
	ansible-playbook -i ../terraform/inventory.yml playbook.yml

deploy-dev: 
	ansible-playbook -i ../terraform/inventory.yml dev-playbook.yml

prepare:
	docker run --rm -d -p 127.0.0.1:5001:5000 -p 172.17.0.1:5001:5000 --name registry registry:2

cleanup:
	docker stop registry

dependencies:
	pip3 install -r requirements.txt --upgrade
	ansible-galaxy collection install --upgrade community.general

inventory:
	ansible-inventory -i ../terraform/inventory.yml --list

.PHONY: default dependencies deploy prepare cleanup inventory
