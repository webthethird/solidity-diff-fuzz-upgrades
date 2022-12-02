import json
import requests
import sys


API_URL = "https://api.compound.finance/api/v2/"


def scrape_accounts(token_symbols: list = None) -> list:
    page = 0
    accounts = []
    while True:
        page += 1
        response = requests.get(
            API_URL+"account",
            params={
                "page_size": 1000,
                "page_number": page,
            }
        )
        data: dict = response.json()
        if "errors" in data.keys():
            print(f"encountered errors:\n{data['errors']}")
            break
        if data["error"] is not None:
            print(f"encountered an error:\n{data['error']}")
            break
        count = 0
        for account in data["accounts"]:
            if account["address"] not in accounts:
                if token_symbols is None or any([symbol in str(account["tokens"]) for symbol in token_symbols]):
                    count += 1
                    accounts.append(account["address"])
        print(f'read {count} unique accounts from page {page}/{data["pagination_summary"]["total_pages"]}')
        if data["pagination_summary"]["total_pages"] == page:
            break
    return accounts


if __name__ == '__main__':
    args = sys.argv[1:]
    if any(["-A" in args, "--all" in args]):
        if "-S" in args:
            symbols = args[args.index("-S") + 1].split(",")
        elif "--symbols" in args:
            symbols = args[args.index("--symbols") + 1].split(",")
        else:
            symbols = None
        accounts_list = scrape_accounts(token_symbols=symbols)
        print(f"Number of accounts scraped: {len(accounts_list)}")
        file_name = "compound_accounts.txt"
        f = open(file_name, "w")
        f.writelines(accounts_list)
        f.close()
        print(f"Wrote list to {file_name}")
