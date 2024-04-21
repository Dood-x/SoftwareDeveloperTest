// original

/*
void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
Player* player = g_game.getPlayerByName(recipient);
if (!player) {
player = new Player(nullptr);
if (!IOLoginData::loadPlayerByName(player, recipient)) {
return;
}
}

Item* item = Item::CreateItem(itemId);
if (!item) {
return;
}

g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

if (player->isOffline()) {
IOLoginData::savePlayer(player);
}
}

*/

void Game::addItemToPlayer(const std::string & recipient, uint16_t itemId)
{

    std::shared_ptr<Player> player = g_game.getPlayerByName(recipient);

    if (!player) {

        //the old line  "player = new Player(nullptr);" causes a memory leak, the player pointer is deleted at the end of the scope
        //of addItemToPlayer but the object allocated on the heap using 'new' lives beyond the scope unreacable as no 'delete' has been used
        //
        //we use a smart pointer that will keep track of the data and delete the object when its not pointed to anymore, rather than needing to keep track and deleting it ourselves
            player = make_shared<Player>(nullptr);
        if (!IOLoginData::loadPlayerByName(player, recipient)) {
            return;
        }
    }

    //according to the OTClient coding standards, we use references or shared_ptr instead of pointers

    std::shared_ptr<Item> item = Item::CreateItem(itemId);
    
    //the OTClient actually has a typedf shared_object_ptr<Item> ItemPtr that would be better used here
    // the line would be ItemPtr item = Item::CreateItem(itemId);

        
    if (!item) {
        return;
    }

    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }
}
