#!/bin/bash

map_images () {
	touch ${_OUTPUTFILES}/${_IMAGE}.csv
	echo "Tag,Created,batch,build-date,Z-Release" > ${_OUTPUTFILES}/${_IMAGE}.csv
	_MAPLOCK=0
	for _TAG in $(skopeo inspect docker://${_REGISTRY}/${_LIBRARY}/${_IMAGE}:latest | jq '.[ "RepoTags" ]' | tr -d '[],"' | sed -e '/^$/d' -e 's/ //g' -e '/^'${_OSPVERS}'$/d' | sort -n -k1.6)
	do
		if (( ${_MAPLOCK} < 6 )); then
			map_z_releases &
			((_MAPLOCK++))
		elif (( ${_MAPLOCK} >= 6 )); then
			wait
			_MAPLOCK=0
		fi
	done
	wait
	(head -n 1 ${_OUTPUTFILES}/${_IMAGE}.csv && tail -n +3 ${_OUTPUTFILES}/${_IMAGE}.csv | sort -n -k1.6) > ${_OUTPUTFILES}/${_IMAGE}_sorted.csv
	mv -f ${_OUTPUTFILES}/${_IMAGE}_sorted.csv ${_OUTPUTFILES}/${_IMAGE}.csv
}

map_z_releases () {
	echo "## Processing ${_IMAGE}:${_TAG}"
	_INSPECTED=$(skopeo inspect docker://${_REGISTRY}/${_LIBRARY}/${_IMAGE}:${_TAG})
	_CREATED=$(echo "${_INSPECTED}" | jq '.[ "Created" ]' | sed -e 's/"//g')
	_BATCH=$(echo "${_INSPECTED}" | jq '.[ "Labels" ]' | jq '.[ "batch" ]' | sed -e 's/"//g')
	_BUILDDATE=$(echo "${_INSPECTED}" | jq '.[ "Labels" ]' | jq '.[ "build-date" ]' | sed -e 's/"//g')

	# The following assumptions are made:
	# - If created more than 7 days earlier it's the previous release
	# - If created +- 7 days it's the current release
	if (( $(date -d "${_CREATED}" +%s) < $(date -d "${_GADATE}-7 days" +%s) )); then
		_ZRELEASE=Beta
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_GADATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_GADATE}+7 days" +%s) )); then
		_ZRELEASE=GA
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_GADATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z1DATE}-7 days" +%s) )); then
		_ZRELEASE=GA.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z1DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z1DATE}+7 days" +%s) )); then
		_ZRELEASE=Z1
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z1DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z2DATE}-7 days" +%s) )); then
		_ZRELEASE=Z1.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z2DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z2DATE}+7 days" +%s) )); then
		_ZRELEASE=Z2
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z2DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z3DATE}-7 days" +%s) )); then
		_ZRELEASE=Z2.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z3DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z3DATE}+7 days" +%s) )); then
		_ZRELEASE=Z3
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z3DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z4DATE}-7 days" +%s) )); then
		_ZRELEASE=Z3.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z4DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z4DATE}+7 days" +%s) )); then
		_ZRELEASE=Z4
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z4DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z5DATE}-7 days" +%s) )); then
		_ZRELEASE=Z4.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z5DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z5DATE}+7 days" +%s) )); then
		_ZRELEASE=Z5
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z5DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z6DATE}-7 days" +%s) )); then
		_ZRELEASE=Z5.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z6DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z6DATE}+7 days" +%s) )); then
		_ZRELEASE=Z6
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z6DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z7DATE}-7 days" +%s) )); then
		_ZRELEASE=Z6.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z7DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z7DATE}+7 days" +%s) )); then
		_ZRELEASE=Z7
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z7DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z8DATE}-7 days" +%s) )); then
		_ZRELEASE=Z7.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z8DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z8DATE}+7 days" +%s) )); then
		_ZRELEASE=Z8
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z8DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z9DATE}-7 days" +%s) )); then
		_ZRELEASE=Z8.async
	elif (( $(date -d "${_CREATED}" +%s) >= $(date -d "${_Z9DATE}-7 days" +%s) && $(date -d "${_CREATED}" +%s) <= $(date -d "${_Z9DATE}+7 days" +%s) )); then
		_ZRELEASE=Z9
	elif (( $(date -d "${_CREATED}" +%s) > $(date -d "${_Z9DATE}+7 days" +%s) && $(date -d "${_CREATED}" +%s) < $(date -d "${_Z10DATE}-7 days" +%s) )); then
		_ZRELEASE=Z9.async
	fi
	echo "${_TAG},${_CREATED},${_BATCH},${_BUILDDATE},${_ZRELEASE}" >> ${_OUTPUTFILES}/${_IMAGE}.csv
}

_REGISTRY="registry.redhat.io"
_TEST="rhel7"
_LIBRARY="rhosp13"
_OSPVERS="13.0"
_IMAGES="openstack-nova-compute openstack-aodh-api openstack-nova-libvirt"
_OUTPUTFILES="./"
_GADATE="2018-06-27"
_Z1DATE="2018-07-19" 
_Z2DATE="2018-08-29"
_Z3DATE="2018-11-13"
_Z4DATE="2019-01-16"
_Z5DATE="2019-03-13"
_Z6DATE="2019-04-30"
_Z7DATE="2019-07-10"
_Z8DATE="2019-09-04"
_Z9DATE="2019-12-01" # Fake dates
_Z10DATE="2020-02-01" # Fake dates

rpm -q docker >/dev/null 2>&1 || yum install -y docker
rpm -q skopeo >/dev/null 2>&1 || yum install -y skopeo
rpm -q jq >/dev/null 2>&1 || yum install -y jq

systemctl enable --now docker

skopeo inspect docker://${_REGISTRY}/${_TEST}:latest >/dev/null 2>&1 || docker login ${_REGISTRY}

_IMAGELOCK=0
for _IMAGE in ${_IMAGES}
do
	if (( ${_IMAGELOCK} < 3 )); then
		map_images &
		((_IMAGELOCK++))
	elif (( ${_IMAGELOCK} >= 3 )); then
		wait
		_IMAGELOCK=0
	fi
done
wait
