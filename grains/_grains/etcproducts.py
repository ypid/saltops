#!/usr/bin/python3
# -*- coding: utf-8 -*-

# SPDX-FileCopyrightText: 2019 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

import os


def os_products():
    grains = {}

    if os.path.isdir('/etc/products.d'):
        grains.update({
            'os_products': []
        })

        for prod in os.listdir("/etc/products.d"):
            if prod in ['baseproduct']:
                continue

            grains['os_products'].append(prod.split('.')[0])

        baseproduct = os.readlink('/etc/products.d/baseproduct')
        grains['os_product_base'] = baseproduct.split('.')[0]

    return grains


if __name__ == "__main__":
    import yaml
    print(yaml.dump(os_products(), default_flow_style=False))
