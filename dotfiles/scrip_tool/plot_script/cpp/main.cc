//************************example***********************************
int main() {
    const size_t count = 1000;
    const size_t max_val = 50;
    int val = 0;
    int flag = 1;
    for (size_t i = 0; i < count; ++i) {
        LOGI("media_info") << "send_speak_count:" << val << " "
                     << "aec_speak_count:" << val + 1 << " "
                     << "sssadsa" << " "
                     << "RTT:" << val + 3 << " "
                     << "send_speak_energy:" << val + 10 << " ";
        LOGI("test") << "ssssssdfsad";
        if (val <= 0) {
            flag = 1;
        } else if (val >= max_val) {
            flag = -1;
        }
        val += flag;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
}

